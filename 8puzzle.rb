#!/usr/bin/ruby
require 'thread'
require 'set'

class State
  # [i, j]
  @@MOVE = {
    :left    => [ 0, -1],  
    :right   => [ 0,  1],
    :up      => [-1,  0],
    :down    => [ 1,  0]}

  def initialize pre_state, pre_move, nums, zero
    @pre_state = pre_state
    @pre_move = pre_move
    @nums = nums
    @zero = zero
  end

  def next_move
    next_states = Array.new
    @@MOVE.each do |k, v|
      dest = [v[0]+@zero[0], v[1]+@zero[1]]
      next if out_of_nums? dest

      deep_copy = Marshal.load Marshal.dump @nums
      next_nums = swap deep_copy, @zero, dest
      next_state = State.new self, k, next_nums, dest
      next_states.push next_state
    end

    next_states
  end

  def out_of_nums? dest
    i_end = @nums.size
    j_end = @nums[0].size
    i = dest[0]
    j = dest[1]

    i < 0 || i_end <= i || j < 0 || j_end <= j
  end
  
  def swap nums, zero, dest
    i1 = zero[0]
    j1 = zero[1]
    i2 = dest[0]
    j2 = dest[1]

    nums[i1][j1], nums[i2][j2] = nums[i2][j2], nums[i1][j1]

    nums
  end
  
  def hash_code
    if @hash == nil
      @hash = 0
      @nums.each do |row|
        row.each do |elem|
          @hash *= 10
          @hash += elem
        end
      end
    end

    @hash
  end

  attr_reader :pre_move, :pre_state
  private :out_of_nums?, :swap
end

def findZero nums
  nums.each_with_index do |row, i|
    row.each_with_index do |elem, j|
      return [i, j] if elem == 0
    end
  end
end


GOAL = 123456780

q = Queue.new
checked = Set.new

nums = [[8, 1, 3],
        [0, 7, 4],
        [6, 5, 2]]
zero = findZero nums
p nums

first_state = State.new nil, nil, nums, zero
checked.add first_state.hash_code
q.push first_state

count = 0
until q.empty?
  now_state = q.pop
  
  # p now_state.nums
  # puts "#{count+=1}: #{now_state.hash_code}"
  
  if now_state.hash_code == GOAL
    solution = Array.new
    until now_state.pre_state == nil
      solution.unshift now_state.pre_move
      now_state = now_state.pre_state
    end
    
    solution.each_with_index do |step, count|
      puts "Step#{count}: #{step}"
    end
    
    break
  end

  now_state.next_move.each do |next_state|
    next if checked.include? next_state.hash_code
      
    checked.add next_state.hash_code
    q.push next_state
  end
end
