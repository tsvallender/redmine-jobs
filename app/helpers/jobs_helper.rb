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
end
