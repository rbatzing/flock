require 'tk'
require_relative 'bird.rb'

WIDTH = 300
HEIGHT = 300

class Plot	
 
     def initialize(parent)
	@parent = parent
	myHeadingFont = TkFont.new("family" => 'Helvetica', 
                    "size" => 15, 
                    "weight" => 'bold')
	 @heading = TkLabel.new(@parent) do
		background "Dark Blue"
		foreground "Yellow"
		font myHeadingFont
		text 'STEP 1: Setup'
		pack { padx 50; pady 15; side 'top' }
	end
	 @canvas = TkCanvas.new(@parent)
	 @canvas.width WIDTH
	 @canvas.height HEIGHT
         @canvas.pack("side"=>"top", "padx" => "5", "pady" => "5")
	 @pointList = Array.new
        @button = TkButton.new(@parent)
	 @button.pack("side"=>"right", "padx" => "10", "pady" => "10")
         updateButton("Add Points", Proc.new { addPoints() })
    end
 
    def updateButton(label, pr) 	    
	@button.configure('text', label)
	@button.configure('command', (proc { pr.call}))
	if @reset.nil? && label.eql?('Choose Key Points')
	   @reset = TkButton.new(@parent)
	   @reset.pack("side"=>"left", "padx" => "10", "pady" => "10")
	   @reset.configure('text', 'Reset values')
	   @reset.configure('command', Proc.new{ reset()})
	end
end

    def reset()
	     @reset.configure('text', 'Reset again')
    end
    
 
    def addPoints
	@heading.configure('text',"STEP 2: Added points")
	20.times do |i|
		@pointList << Point.new(rand(WIDTH), rand(HEIGHT))
		@pointList[i].show(@canvas,'blue')
	end
	
         updateButton("Choose Key Points", Proc.new { chooseKeyPoints() })
    end
    
    def chooseKeyPoints
	@heading.configure('text',"STEP 3: Choosen key points")
	left = 0; leftval = @pointList[0].x
	right = 0; rightval = @pointList[0].x
	top = 0; topval = @pointList[0].y
	bottom = 0; bottomval = @pointList[0].y
	
	(1..@pointList.size - 1).each do |i|
		if @pointList[i].x < leftval
			leftval = @pointList[i].x
			left = i
		elsif @pointList[i].x > rightval
			rightval = @pointList[i].x
			right = i
		end
		
		if @pointList[i].y < topval
			topval = @pointList[i].y
			top = i
		elsif @pointList[i].y > bottomval
			bottomval = @pointList[i].y
			bottom = i
	        end
			
	end
	@edges = [left,top,right,bottom]
	
	@edges.each do |i|
		@pointList[i].boundary = true
	end
	drawLine(@pointList[left],@pointList[top],'orange')
	
        TkcLine.new(@canvas, @pointList[top].x,@pointList[top].y, 
		@pointList[right].x,@pointList[right].y, 
	        smooth: 'on',  width: 1, fill: 'orange')
	TkcLine.new(@canvas, @pointList[right].x,@pointList[right].y, 
		@pointList[bottom].x,@pointList[bottom].y, 
	        smooth: 'on',  width: 1, fill: 'orange')
	TkcLine.new(@canvas, @pointList[bottom].x,@pointList[bottom].y, 
		@pointList[left].x,@pointList[left].y, 
	        smooth: 'on',  width: 1, fill: 'orange')

	updateButton("Find boundary points", Proc.new { findBoundary() }) 
    end
    
    
    def findBoundary
	@heading.configure('text',"STEP 4: Hull Boundary")
	@pointList.each do |p|
			drawLine(@pointList[@edges[0]],
			@pointList[@edges[1]],"green")
			drawLine(@pointList[@edges[1]],
			@pointList[@edges[2]],"green")
			drawLine(@pointList[@edges[2]],
			@pointList[@edges[0]],"green")

                if p.inTriangle?(@pointList[@edges[0]],
			@pointList[@edges[1]],
			@pointList[@edges[2]])

				p.show(@canvas,"green")
				p.display = false
		end
			
		 if  p.inTriangle?(@pointList[@edges[0]],
			@pointList[@edges[3]],
			@pointList[@edges[2]])
			drawLine(@pointList[@edges[0]],
			@pointList[@edges[3]],"black")
			drawLine(@pointList[@edges[3]],
			@pointList[@edges[2]],"black")
			drawLine(@pointList[@edges[2]],
			@pointList[@edges[0]],"black")
			p.show(@canvas,"black")
			p.display = false
		end
	end
	
	@pointList.each do |p|
		if p.display
			p.show(@canvas,'red')
		end
		puts p.inspect
	end
	
	updateButton("Exit", Proc.new { exit })
    end
    
    
    def drawHull
	@heading.configure('text',"STEP 5: Drawn hull")
	updateButton("Exit", Proc.new { exit })
    end


     def drawLine(pt1,pt2,color)
	TkcLine.new(@canvas, pt1.x, pt1.y, pt2.x, pt2.y, 
	        smooth: 'on',  width: 1, fill: color)
    end
 end
 
 
 class Point
	 attr_accessor :x, :y,:display,:boundary
	 
   def initialize(x,y)
	  @x = x
	  @y = y
	  @display = true
	  @boundary = false
   end
  
   def hide
	  @display =false
   end
  
    def show(canvas,col ='blue')
	if @display
	   TkcLine.new(canvas, @x-1, @y+1, @x+1,@y-1, smooth: 'on',  width: 3, fill: col)
	   TkcLine.new(canvas, @x-1, @y-1, @x+1,@y+1, smooth: 'on',  width: 3, fill: col)
       end
   end
   
   def deltaY(pt)
	return @y-pt.y
   end

   def deltaX(pt)
	   return @x -pt.x
   end
   
   def inTriangle?(p1,p2,p3)
	   
	denom =  (1.0 * p2.deltaY(p3) * p1.deltaX(p3)) + 
	    (p3.deltaX(p2) * p1.deltaY(p3))

	alpha = ((1.0 * p2.deltaY(p3) * deltaX(p3)) + 
	   (p3.deltaX(p2) * deltaY(p3))) / denom
	  
		  
	beta =((1.0 * p3.deltaY(p1) * deltaX(p3)) +
	    (p1.deltaX(p3) * deltaY(p3))) / denom

	gamma = (1.0 - alpha) -beta
	  
        print "%.2f %.2f + " % [alpha*@x, alpha*@y]
	print "%.2f %.2f + " % [beta*@x, beta*@y]
	print "%.2f %.2f = " % [gamma * @x, gamma * @y]
	print "%.2f " % [(alpha + beta + gamma) * @x]
	print "%.2f " % [(alpha + beta + gamma) * @y]
	puts "(%.2f %.2f)" % [@x, @y]
	
	
	return ((alpha >= 0) && (beta >= 0)  && (gamma >= 0) &&
	    (alpha <= 1) && (beta <= 1)  && (gamma <=1) )
    end
   

end
  
	  
 
root = TkRoot.new {title "Bird Flock Simulator"}
=begin
$birdscale = TkScale.new {
  orient 'horizontal'
  length 280
  from 0
  to 250
  command (proc {printheight})
  tickinterval 50
  pack
}

def printheight
  height = $scale.get()
  print height, "\n"
end

=end



Plot.new(root)

Tk.mainloop()