class Deferred::ConfirmationsController < ApplicationController
  helper_method :booked_visit
  permit_only_from_prisons

  def new
    reset_session if params[:state]
    @confirmation = Confirmation.new
    metrics_logger.record_link_click(booked_visit)
    if metrics_logger.processed?(booked_visit)
      reset_session
      STATSD_CLIENT.increment('pvb.app.already_booked')
      render '_already_booked'
    end
    logstasher_add_visit_id(booked_visit.visit_id)
  rescue ActiveSupport::MessageVerifier::InvalidSignature => e
    render '_bad_state', status: 400
    STATSD_CLIENT.increment('pvb.app.bad_state')
    Raven.capture_exception(e)
  end

  def create
   unless params[:confirmation] && (@confirmation = Confirmation.new(confirmation_params)).valid?
      return render :new
    end

    if @confirmation.slot_selected?
      VisitorMailer.booking_confirmation_email(booked_visit, @confirmation).deliver
      metrics_logger.record_booking_confirmation(booked_visit)
    else
      VisitorMailer.booking_rejection_email(booked_visit, @confirmation).deliver
      metrics_logger.record_booking_rejection(booked_visit, @confirmation.outcome)
    end
    PrisonMailer.booking_receipt_email(booked_visit, @confirmation).deliver
    redirect_to deferred_confirmation_path
  end

  def show
    reset_session
  end

  def booked_visit
    remove_prison(legacy_data_fixes(encryptor.decrypt_and_verify(params[:state])))
  end

  def confirmation_params
    params.require(:confirmation).permit(:outcome, :message, :vo_number, :no_vo, :no_pvo, :renew_vo, :renew_pvo, :visitor_not_listed, :visitor_banned, :canned_response, banned_visitors: [], unlisted_visitors: [])
  end

  def encryptor
    MESSAGE_ENCRYPTOR
  end

  def metrics_logger
    METRICS_LOGGER
  end

  def legacy_data_fixes(visit)
    if prison_name = {
        'Hollesley Bay' => 'Hollesley Bay Open',
        'Hatfield (moorland Open)' => 'Hatfield Open',
        'Highpoint' => 'Highpoint North',
        'Albany' => 'Isle of Wight - Albany',
        'Parkhurst' => 'Isle of Wight - Parkhurst',
        'Liverpool (Open only)' => 'Liverpool Social Visits'
      }[visit.prisoner.prison_name]
      STATSD_CLIENT.increment('pvb.app.legacy_data_fixes')
      visit.prisoner.prison_name = prison_name
    end
    visit
  end

  def remove_prison(visit)
    visit.tap do |v|
      if v.prisoner.prison
        STATSD_CLIENT.increment('pvb.app.remove_prison')
        v.prisoner.prison = nil
      end
    end
  end

  def migrate_visitors(visit)
    visit.dup.tap do |visit|
      visit.visitors.map! do |visitor|
        if visitor.class == Visitor
          values = [:first_name, :last_name, :email, :index, :number_of_adults, :number_of_children, :date_of_birth, :phone].inject({}) do |h, selector|
            h[selector] = visitor.send(selector)
            h
          end
          Deferred::Visitor.new(values)
        else
          visitor
        end
      end
    end
  end
end
