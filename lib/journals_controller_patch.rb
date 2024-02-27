# frozen_string_literal: true

require_dependency 'journals_controller'

module JournalsControllerPatch
  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    alias_method :original_diff, :diff
    alias_method :diff, :new_diff
    alias_method :original_find_journal, :find_journal
    alias_method :find_journal, :new_find_journal
  end

  module InstanceMethods
    def new_diff
      @journalized = @journal.journalized
      if params[:detail_id].present?
        @detail = @journal.details.find_by_id(params[:detail_id])
      else
        @detail = @journal.details.detect {|d| d.property == 'attr' && d.prop_key == 'description'}
      end
      unless @journalized && @detail
        render_404
        return false
      end
      if @detail.property == 'cf'
        unless @detail.custom_field && @detail.custom_field.visible_by?(@journalized.project, User.current)
          raise ::Unauthorized
        end
      end
      @diff = Redmine::Helpers::Diff.new(@detail.value, @detail.old_value)
    end

    # The find_journal method in the controller assumes journalized is an Issue, so we need
    # to be a bit silly about it.
    def new_find_journal
      @journal = Journal.find(params[:id])
      if @journal.journalized.is_a?(Issue)
        original_find_journal and return
      end

      @project = @journal.journalized.project
      @issue = @journal.journalized
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end
