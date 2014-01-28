class AboutController < ApplicationController
  def main
    checkDevice()
  end
  
  def contact
  end
  
  def entry
  end
  
  def irb
  end
  
  def data
  end
  
  def checkDevice() 
    if browser.safari?
      @browser = :safari
    else
      @browser = :other
    end
  end
end
