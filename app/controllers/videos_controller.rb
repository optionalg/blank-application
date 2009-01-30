class VideosController < ApplicationController	
  acts_as_ajax_validation
	acts_as_item do
    after :create, :update do
      #Call the encoder method of ConverterWorker with parameters
      @current_object.update_attributes(:state=>"uploaded")
      MiddleMan.worker(:converter_worker).async_encoder(:arg=>{:type=>"video", :id => @current_object.id, :enc=>"flv"})
   end
  end

  def get_progress
    @current_object=Video.find_by_id(params[:id])
    if @current_object.state=="encoded"
     render :partial=>"player"
    elsif @current_object.state=="encoding"
      render :partial=>"status"
    else
      render :nothing=>true
   end
  end
end