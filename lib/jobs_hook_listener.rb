class JobsHookListener < Redmine::Hook::ViewListener
  render_on :view_timelog_edit_form_bottom, partial: "timelogs/edit_form_bottom"
  render_on :view_users_form, partial: "users/edit_form"
end

