# frozen_string_literal: true

module SovoContractsHelper
  def sovo_contract_status(submission)
    return ['已完成', 'badge-success'] if submission.completed_at?
    return ['已过期', 'badge-error'] if submission.expired?
    return ['有签署人拒绝', 'badge-error'] if submission.submitters.any?(&:declined_at?)
    return ['签署进行中', 'badge-warning'] if submission.submitters.any? { |submitter| %w[opened completed].include?(submitter.status) }

    ['待签署', 'badge-info']
  end

  def sovo_signer_status(submitter)
    {
      'awaiting' => '等待邀请',
      'sent' => '已发送',
      'opened' => '已查看',
      'completed' => '已签署',
      'declined' => '已拒绝'
    }.fetch(submitter.status, submitter.status)
  end
end
