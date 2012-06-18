module SendgridPostback
  class Event

    ORDER = {
      processed: 1,
      dropped: 1,
      deferred: 1,
      delivered: 2,
      bounce: 2,
      open: 3,
      click: 4,
      unsubscribe: 4,
      spamreport: 4
    }

    def self.order(val)
      ORDER[val] || 99
    end

    # Events are not ordered by SendgridPostback, either by arrival nor timestamp.
    # http://docs.sendgrid.com/documentation/api/event-api/
    def self.sorted events
      state = nil
      normalize_events(events).sort do |x, y|
        ord = order(x[:event]) <=> order(y[:event])
        ord = x[:timestamp] <=> y[:timestamp] if ord == 0
        ord
      end
    end

    def self.normalize_events events
      events = events.map{|x| HashWithIndifferentAccess.new(x)}
      events.map do |event|
        event[:event] = event[:event].to_sym
        event[:timestamp] = event[:timestamp].to_i
        event
      end
      events
    end

  end
end
