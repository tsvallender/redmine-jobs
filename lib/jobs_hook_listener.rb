class JobsHookListener < Redmine::Hook::ViewListener
  render_on :view_time_entries_bulk_edit_details_bottom, partial: "time_entries/bulk_edit_details_bottom"
  render_on :view_timelog_edit_form_bottom, partial: "time_entries/edit_form_bottom"
  render_on :view_users_form, partial: "users/edit_form"
end

