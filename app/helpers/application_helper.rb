module ApplicationHelper
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
end
