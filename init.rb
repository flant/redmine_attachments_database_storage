require 'redmine'
require File.dirname(__FILE__) + '/lib/ds_attachments_controller_patch.rb'
require File.dirname(__FILE__) + '/lib/ds_attachment_patch.rb'
require 'dispatcher'

Redmine::Plugin.register :redmine_attachments_database_storage do
  name 'Redmine Attachments Database Storage plugin'
  author 'Andrey Kolashtov <andrey.kolashtov@flant.ru>'
  description 'This is a plugin for Redmine which allows to store attachments in database'
  version '0.0.1'
  url 'https://github.com/flant/redmine_attachments_database_storage'
  author_url 'https://github.com/kolashtov'
end

# With dispatcher patch applies on model classes on every request.
Dispatcher.to_prepare do
  AttachmentsController.send(:include, DsAttachmentsControllerPatch)
  Attachment.send(:include, DsAttachmentPatch)
end
