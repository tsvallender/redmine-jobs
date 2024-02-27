module JobsHelper
  def total_progress_bar(job)
    progress_bar(job.done_ratio,
                 legend: "#{job.done_ratio}%
                          (#{l_hours_short(job.total_time_logged)}/#{l_hours_short(job.total_time_budget)})",
                 class: "progress")
  end

  def progress_bar_for(budget)
    progress_bar(budget.done_ratio,
                 legend: "#{budget.done_ratio}%
                          (#{l_hours_short(budget.total_time_logged)}/#{l_hours_short(budget.hours)})",
                 class: "progress")
  end

  def job_history_tabs
    tabs = []

    if @journals.present?
      has_notes = @journals.any? { |journal| journal.notes.present? }
      tabs <<
        {
          name: "history",
          label: "History",
          onclick: 'showIssueHistory("history", this.href)',
          partial: "jobs/tabs/history",
          locals: {
            job: @job,
            journals: @journals
          }
        }
      if has_notes
        tabs << {
          name: "notes",
          label: "Notes",
          onclick: 'showIssueHistory("notes", this.href)',
        }
      end
    end
    tabs
  end

  def job_history_default_tab
    return params[:tab] if params[:tab].present?

    "history"
  end

  # Below methods copied directly from issues_helper with few adjustments


  # Returns the textual representation of a journal details
  # as an array of strings
  def details_to_strings(details, no_html=false, options={})
    options[:only_path] = !(options[:only_path] == false)
    strings = []
    values_by_field = {}
    details.each do |detail|
      if detail.property == 'cf'
        field = detail.custom_field
        if field && field.multiple?
          values_by_field[field] ||= {:added => [], :deleted => []}
          if detail.old_value
            values_by_field[field][:deleted] << detail.old_value
          end
          if detail.value
            values_by_field[field][:added] << detail.value
          end
          next
        end
      end
      strings << show_detail(detail, no_html, options)
    end
    if values_by_field.present?
      values_by_field.each do |field, changes|
        if changes[:added].any?
          detail = MultipleValuesDetail.new('cf', field.id.to_s, field)
          detail.value = changes[:added]
          strings << show_detail(detail, no_html, options)
        end
        if changes[:deleted].any?
          detail = MultipleValuesDetail.new('cf', field.id.to_s, field)
          detail.old_value = changes[:deleted]
          strings << show_detail(detail, no_html, options)
        end
      end
    end
    strings
  end

  def show_detail(detail, no_html=false, options={})
    multiple = false
    show_diff = false
    no_details = false

    case detail.property
    when 'attr'
      field = detail.prop_key.to_s.gsub(/\_id$/, "")
      label = l(("field_" + field).to_sym)
      case detail.prop_key
      when 'due_date', 'start_date'
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value
      when 'project_id', 'category_id'
        value = find_name_by_reflection(field, detail.value)
        old_value = find_name_by_reflection(field, detail.old_value)
      when 'description'
        show_diff = true
      end
    when 'relation'
      if detail.value && !detail.old_value
        rel_issue = Issue.visible.find_by_id(detail.value)
        value =
          if rel_issue.nil?
            "#{l(:label_issue)} ##{detail.value}"
          else
            (no_html ? rel_issue : link_to_issue(rel_issue, :only_path => options[:only_path]))
          end
      elsif detail.old_value && !detail.value
        rel_issue = Issue.visible.find_by_id(detail.old_value)
        old_value =
          if rel_issue.nil?
            "#{l(:label_issue)} ##{detail.old_value}"
          else
            (no_html ? rel_issue : link_to_issue(rel_issue, :only_path => options[:only_path]))
          end
      end
      relation_type = IssueRelation::TYPES[detail.prop_key]
      label = l(relation_type[:name]) if relation_type
    end
    call_hook(:helper_issues_show_detail_after_setting,
              {:detail => detail, :label => label, :value => value, :old_value => old_value})

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value

    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      if detail.old_value && detail.value.blank? && detail.property != 'relation'
        old_value = content_tag("del", old_value)
      end
      if detail.property == 'attachment' && value.present? &&
          atta = detail.journal.journalized.attachments.detect {|a| a.id == detail.prop_key.to_i}
        # Link to the attachment if it has not been removed
        value = link_to_attachment(atta, only_path: options[:only_path])
        if options[:only_path] != false
          value += ' '
          value += link_to_attachment atta, class: 'icon-only icon-download', title: l(:button_download), download: true
        end
      else
        value = content_tag("i", h(value)) if value
      end
    end

    if no_details
      s = l(:text_journal_changed_no_detail, :label => label).html_safe
    elsif show_diff
      s = l(:text_journal_changed_no_detail, :label => label)
      unless no_html
        diff_link =
          link_to(
            l(:label_diff),
            diff_journal_url(detail.journal_id, :detail_id => detail.id,
                             :only_path => options[:only_path]),
            :title => l(:label_view_diff))
        s << " (#{diff_link})"
      end
      s.html_safe
    elsif detail.value.present?
      case detail.property
      when 'attr', 'cf'
        if detail.old_value.present?
          l(:text_journal_changed, :label => label, :old => old_value, :new => value).html_safe
        elsif multiple
          l(:text_journal_added, :label => label, :value => value).html_safe
        else
          l(:text_journal_set_to, :label => label, :value => value).html_safe
        end
      when 'attachment', 'relation'
        l(:text_journal_added, :label => label, :value => value).html_safe
      end
    else
      l(:text_journal_deleted, :label => label, :old => old_value).html_safe
    end
  end

  # Find the name of an associated record stored in the field attribute
  # For project, return the associated record only if is visible for the current User
  def find_name_by_reflection(field, id)
    return nil if id.blank?

    @detail_value_name_by_reflection ||= Hash.new do |hash, key|
      association = Job.reflect_on_association(key.first.to_sym)
      name = nil
      if association
        record = association.klass.find_by_id(key.last)
        if (record && !record.is_a?(Project)) || (record.is_a?(Project) && record.visible?)
          name = record.name.force_encoding('UTF-8')
        end
      end
      hash[key] = name
    end
    @detail_value_name_by_reflection[[field, id]]
  end

  def render_notes(issue, journal, options={})
    content_tag('div', textilizable(journal, :notes), :id => "journal-#{journal.id}-notes", :class => "wiki")
  end
end
