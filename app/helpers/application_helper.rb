module ApplicationHelper
	include Authentication
	def horizon_form_for(record, options = {}, &block)
		options = options.merge(
		html: { class: 'form-horizontal' },
		wrapper: :horizontal_form,
		wrapper_mappings: {
		check_boxes: :horizontal_radio_and_checkboxes,
		radio_buttons: :horizontal_radio_and_checkboxes,
		file: :horizontal_file_input,
		boolean: :horizontal_boolean
		}
		)
		simple_form_for(record, options, &block)
	end
	def vertical_form_for(record, options = {}, &block)
		options = options.merge(
		html: { class: 'vertical_form' },
		wrapper: :vertical_form,
		wrapper_mappings: {
		check_boxes: :vertical_radio_and_checkboxes,
		radio_buttons: :vertical_radio_and_checkboxes,
		file: :vertical_file_input,
		boolean: :vertical_boolean
		}
		)
		simple_form_for(record, options, &block)
	end
	def inline_form_for(record, options = {}, &block)
		options = options.merge(
		html: { class: 'inline_form' },
		wrapper: :inline_form,
		wrapper_mappings: {
		check_boxes: :inline_radio_and_checkboxes,
		radio_buttons: :inline_radio_and_checkboxes,
		file: :inline_file_input,
		boolean: :inline_boolean
		}
		)
		simple_form_for(record, options, &block)
	end
  def qiniu_or_noimage(bucket_url,key)
    if key.present?
      return "#{current_user.bucket_url}/#{key}"
    else
      return 'no-img.png'
    end
  end

end
