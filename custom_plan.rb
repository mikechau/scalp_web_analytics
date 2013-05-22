require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def after_fork
  #   srand
  #   super
  # end

  def default_bundle_with_test_env
    ::Rails.env = 'test'
    ENV['RAILS_ENV'] = 'test'
    default_bundle
  end

  def test_console
    console
  end
end

Zeus.plan = CustomPlan.new