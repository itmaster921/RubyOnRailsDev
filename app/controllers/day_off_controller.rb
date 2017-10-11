class DayOffController < ApplicationController
  def create
    place = if params[:dayoff][:venue]
              Venue.find(params[:venue_id])
            else
              Court.find(params[:dayoff][:court_id])
            end
    @dayoff = place.day_offs.build(dayoff_params)
    if @dayoff.save
      render nothing: true, status: :ok
    else
      render nothing: true, status: 401
    end
  end

  def destroy
    @dayoff = DayOff.find(params[:id]).destroy
    render json: @dayoff, status: :ok
  end

  private

  def dayoff_params
    dparams = params.require(:dayoff).permit(:start_time, :end_time,
                                             :place)
    dparams[:start_time] = TimeSanitizer.input("#{params[:dayoff][:start_date]}\
                                                #{dparams[:start_time]}")
    dparams[:end_time] = TimeSanitizer.input("#{params[:dayoff][:end_date]}\
                                              #{dparams[:end_time]}")
    dparams
  end
end
