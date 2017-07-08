class Player

  attr_reader :glass

  # params with index from server
  DATA_PARAMS = {
                  'figure'  => 0,
                  'x'       => 1,
                  'y'       => 2,
                  'glass'   => 3,
                  'next'    => 4
                }

  # rotate options
  DO_NOT_ROTATE = 0
  ROTATE_90_CLOCKWISE = 1
  ROTATE_180_CLOCKWISE = 2
  ROTATE_90_COUNTERCLOCKWISE = 3

  # possible figures
  FIGURES = {
              'O' => {}, # cube
              'I' => {}, # |
              'J' => {}, # _|
              'L' => {}, # |_
              'S' => {}, # _|-
              'Z' => {}, # -|_
              'T' => {}  # _|_
    }

  def initialize
    @glass = Glass.new
    self
  end

  # process data for each event from tetris-server
  def process(data)
    @figure, @x, @y, raw_glass, next_str = data_to_params(data)
    @next_figures = next_str.split('')
    @glass.update_state(raw_glass)
  end

  # This method should return string like left=0, right=0, rotate=0, drop'
  def step
    # print glass state
    @glass.print_glass

    # possible actions: left, right, rotate, drop
    available_actions = %i(left right rotate)
    actions_count = rand(1..2)
    actions = available_actions.sample(actions_count)
    random_actions = actions.inject({}) do |res, action|
      res[action] = rand(1..3)
      res
    end

    result = random_actions.to_a.map do |action|
      "#{action.first}=#{action.last}"
    end.join(',')

    puts "Dancing like #{result}"
    "#{result},drop"
  end

  # This method is used for processing event from tetris-server to params for client
  def data_to_params(data)
    raise 'No data to prepare params' unless data
    res = []
    DATA_PARAMS.each do |k, v|
      res << data.split('&')[v].gsub!("#{k}=", '')
    end
    res
  end
  private :data_to_params
end
