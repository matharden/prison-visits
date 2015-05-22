class VisitController < ApplicationController

  def abandon
    reset_session
  end

  def status
    @visit_status = metrics_logger.visit_status(params[:id])
    if params[:state]
      encryptor.decrypt_and_verify(params[:state])
      @state = params[:state]
    else
      statsd_increment('pvb.app.status_with_no_state')
    end
  end

  def update_status
    @visit_status = metrics_logger.visit_status(params[:id])
    @visit = encryptor.decrypt_and_verify(params[:state])

    if params[:cancel]
      if @visit_status == 'pending'
        metrics_logger.record_booking_cancellation(params[:id], 'request_cancelled')
      else
        prison_mailer.booking_cancellation_receipt_email(@visit).deliver
        metrics_logger.record_booking_cancellation(params[:id], 'visit_cancelled')
      end
    else
      flash[:notice] = "You need to confirm that you want to cancel this visit."
    end

    redirect_to visit_status_path(id: params[:id], state: params[:state])
  end

  def encryptor
    MESSAGE_ENCRYPTOR
  end
end
