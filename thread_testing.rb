def do_thing
  thread_1_ended_at, thread_2_ended_at = nil, nil
  threads = []

  threads << Thread.new do
    ActiveRecord::Base.transaction do
      TransferGroup.joins(:ach_transfers).where(transfers: {status: AchTransfer.statuses[:not_started]}).lock.to_a
      sleep 3
    end

    thread_1_ended_at = Time.now
  end

  threads << Thread.new do
    sleep 1

    ActiveRecord::Base.transaction do
      Transfer.update_all(status: 0)
    end

    thread_2_ended_at = Time.now
  end

  threads.map(&:join)

  return thread_1_ended_at, thread_2_ended_at
end

def do_thing_2
  thread_1_ended_at, thread_2_ended_at = nil, nil
  threads = []

  threads << Thread.new do
    ActiveRecord::Base.transaction do
      TransferGroup.all.lock.to_a
      sleep 3
    end

    thread_1_ended_at = Time.now
  end

  threads << Thread.new do
    sleep 1

    ActiveRecord::Base.transaction do
      Transfer.update_all(status: 0)
    end

    thread_2_ended_at = Time.now
  end

  threads.map(&:join)

  return thread_1_ended_at, thread_2_ended_at
end
