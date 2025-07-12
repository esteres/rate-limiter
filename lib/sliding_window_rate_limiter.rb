require "redis"

class SlidingWindowRateLimiter
  def initialize(redis:, time_window:, max_requests:)
    @redis = redis
    @time_window = time_window
    @max_requests = max_requests
  end

  def allow_request?(timestamp, user_id)
    key = redis_key(user_id)
    now = timestamp.to_f
    window_start = now - @time_window

    @redis.zremrangebyscore(key, 0, window_start)

    current_count = @redis.zcard(key)

    if current_count < @max_requests
      @redis.zadd(key, now, now)

      @redis.expire(key, @time_window + 60)

      true
    else
      false
    end
  end

  private

  def redis_key(user_id)
    "rate_limiter:#{user_id}"
  end
end
