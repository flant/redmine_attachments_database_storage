require_dependency 'attachments_controller'

module DsAttachmentsControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      def download
        if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
          @attachment.increment_download
        end
        
        # images are sent inline
        send_data @attachment.data, :filename => filename_for_content_disposition(@attachment.filename),
          :type => detect_content_type(@attachment),
          :disposition => (@attachment.image? ? 'inline' : 'attachment')
      end

      def show
        respond_to do |format|
          format.html {
            if @attachment.is_diff?
              @diff = @attachment.data
              @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
              @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)
              # Save diff type as user preference
              if User.current.logged? && @diff_type != User.current.pref[:diff_type]
                User.current.pref[:diff_type] = @diff_type
                User.current.preference.save
              end
              render :action => 'diff'
            elsif @attachment.is_text? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
              @content = @attachment.data
              render :action => 'file'
            else
              download
            end
          }
          format.api
        end
      end
    end


  end

  module ClassMethods
  end

  module InstanceMethods
  end
end