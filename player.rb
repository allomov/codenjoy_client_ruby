require 'pry'


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

  class Figure
    attr_accessor :type, :required_space, :x, :y
    attr_accessor :fill_matrix


    def initialize(type, x, y)
      @x, @y = x, y
      @required_space = case type
      when 'O'
        2
      when 'I'
        1
      else
        3
      end
    end

    def update(glass, action)
    end
  end

  class Action
    attr_accessor :type, :count
    def initialize(type, count)
      @type, @count = type, count
    end
    def move_direction_coefficient
      type == :left ? -1 : 1
    end
  end

  def find_best_place(figure)
    raise "wowow error" unless figure.kind_of?(Player::Figure)
    # available_actions = %i(left right rotate)
    available_actions = %i(left right)
    available_actions_with_moves = available_actions.inject([]) do |res, action|
      (1..5).to_a.map { |action_count| res.push(Action.new(action, action_count)) }
      res
    end

    ratings = available_actions_with_moves.map do |action|
      calculate_rating(glass, figure, action)
    end
  end

  def calculate_rating(glass, figure, action)
    raise "wowow error" unless figure.kind_of?(Player::Figure)
    raise "wowow error" unless action.kind_of?(Player::Action)
    res_glass = resulting_glass(glass, figure, action)
    rate_glass(glass)
  end

  def rate_glass(glass)
    rows_count = glass.size
    glass.state.each_with_index.inject(0) do |res, row_with_index|
      row = row_with_index.first
      ind = row_with_index.last
      filled_cells_in_row = row.find_all { |el| el == "*" }.count
      res += filled_cells_in_row.to_f * (rows_count - ind) / rows_count
      res
    end
  end

  def resulting_glass(glass, figure, action)
    binding.pry
    result_x = action.move_direction_coefficient * action.count + figure.x

  end

  # This method should return string like left=0, right=0, rotate=0, drop'
  def step
    # print glass state
    @glass.print_glass

    best_position = find_best_place(Figure.new(@figure, @x, @y))

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
