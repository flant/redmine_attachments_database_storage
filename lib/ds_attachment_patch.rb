require_dependency 'attachment'

module DsAttachmentPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      def readable?
        true
      end

      def delete_from_disk
        !filename.blank?
      end  
      
      # Copies the temporary file to its final location
      # and computes its MD5 hash
      def files_to_final_location
        if @temp_file && (@temp_file.size > 0)
          logger.info("Saving attachment '#{self.filename}' (#{@temp_file.size} bytes) to database")
          md5 = Digest::MD5.new
          buffer = ""
          self.data = ""
          while (buffer = @temp_file.read(8192))
            md5.update(buffer)
            self.data << buffer
          end
          self.digest = md5.hexdigest
        end
        @temp_file = nil
        # Don't save the content type if it's longer than the authorized length
        if self.content_type && self.content_type.length > 255
          self.content_type = nil
        end
      end
    
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end