class Bird
  attr_accessor :x, :y, :flock, :scale, :flocksize, :process, :flockname, :label
 @@flockCount = 0

  def update
  @flocksize = @scale.get()
  print @flocksize, "\n"
end

  def initialize(flkname) 
	tf = TkFrame.new do
	   pady 5
	   padx 5
	   width 800
	   pack {side 'top'}
	end
	   
	@flockname = flkname
	@label = TkLabel.new(tf) do
		background "Dark Blue"
		foreground "Yellow"
		
		pack { padx 5; pady 2; side 'left' }
	end
	@label.configure('text',@flockname)
	@scale = TkScale.new(tf) {
		orient 'horizontal'
		length 280
		from 0
		to 250
		tickinterval 50
		pack { padx 5; pady 1; side 'right' }
	}
	@scale.configure('command', ( Proc.new { update() }))

end


  
  def checkforward
  end	  

end

