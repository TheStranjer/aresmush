$:.unshift File.join(File.dirname(__FILE__), *%w[.. engine])

require "aresmush"

module AresMUSH

  describe SubstitutionFormatter do
    before do
      allow(Line).to receive(:show) { "" }
    end
    
    describe :perform_subs do
      before do
        @enactor = { "name" => "Bob" }
      end

      it "should replace %r and %R with linebreaks" do
        expect(SubstitutionFormatter.format("Test%rline%Rline2")).to eq "Test\nline\nline2"
      end
      
      it "should replace %b and %B with blank space" do
        expect(SubstitutionFormatter.format("Test%bblank%Bspace")).to eq "Test blank space"
      end

      it "should replace %t and %T with 5 spaces" do
        expect(SubstitutionFormatter.format("Test%tTest2%TTest3")).to eq "Test     Test2     Test3"
      end

      it "should replace %lh with header" do
        allow(Line).to receive(:show).with("h") { "---" }
        expect(SubstitutionFormatter.format("Test%lhTest")).to eq "Test---Test"
      end    

      it "should replace %lf with footer" do
        allow(Line).to receive(:show).with("f") { "---" }
        expect(SubstitutionFormatter.format("Test%lfTest")).to eq "Test---Test"
      end    

      it "should replace %ld with divider" do
        allow(Line).to receive(:show).with("d") { "---" }
        expect(SubstitutionFormatter.format("Test%ldTest")).to eq "Test---Test"
      end    

      it "should replace %lp with plain line" do
        allow(Line).to receive(:show).with("p") { "---" }
        expect(SubstitutionFormatter.format("Test%lpTest")).to eq "Test---Test"
      end  
      
      it "should replace %LP with plain line (case doesn't matter)" do
        allow(Line).to receive(:show).with("P") { "---" }
        expect(SubstitutionFormatter.format("Test%LPTest")).to eq "Test---Test"
      end    
      
      it "should replace %x! with a random color" do
        expect(AresMUSH::RandomColorizer).to receive(:random_color) { "%xb" }
        expect(SubstitutionFormatter.format("A%x!B")).to eq "A" + ANSI.blue + "B"
      end

      it "should replace %\\ with a \\" do
        expect(SubstitutionFormatter.format("A%\\B")).to eq "A\\B"
      end
      
      it "should replace space() with spaces" do
        expect(SubstitutionFormatter.format("A[space(1)]B[space(10)]")).to eq "A B          "
      end

      it "should replace center() with centered text" do
        expect(SubstitutionFormatter.format("[center(A,5)]B")).to eq "  A  B"
      end
      
      it "should replace center() with centered text with a padding char" do
        expect(SubstitutionFormatter.format("[center(A,6,.)]B")).to eq "..A...B"
      end

      it "should replace left() with left text with a padding char" do
        expect(SubstitutionFormatter.format("[left(A,6,.)]B")).to eq "A.....B"
      end

      it "should replace right() with right text with a padding char" do
        expect(SubstitutionFormatter.format("[right(A,6,.)]B")).to eq ".....AB"
      end
      
      it "should replace ansi() with ansi codes" do
        expect(SubstitutionFormatter.format("[ansi(hcB,A)]")).to eq ANSI.bold + ANSI.cyan + ANSI.on_blue + "A" + ANSI.reset
      end
      
      it "should not replace an escaped linebreak or space" do
        expect(SubstitutionFormatter.format("Test\\%bblank\\%Rline")).to eq "Test\\%bblank\\%Rline"
      end
      
      it "should replace nested codes" do
        expect(SubstitutionFormatter.format("A%xc%xGB%xnC")).to eq "A" + ANSI.cyan + ANSI.on_green + "B" + ANSI.reset + "C" 
      end

      it "should not replace a code preceeded by a backslash" do
        expect(SubstitutionFormatter.format("A\\%xcB")).to eq "A\\%xcB" 
      end
      
      it "should handle a numeric code for foreground" do
        expect(SubstitutionFormatter.format("A%x102B")).to eq "A\e[38;5;102mB" 
      end
      
      it "should handle a numeric code for background" do
        expect(SubstitutionFormatter.format("A%C102B")).to eq "A\e[48;5;102mB" 
      end
      
      it "should handle a color code followed by a number" do
        expect(SubstitutionFormatter.format("A%Cg123B")).to eq "A" + ANSI.green + "123B" 
      end
      
    end
    
    
    describe :center do
      it "should truncate if the string is too long" do
        expect(SubstitutionFormatter.center("A%xc%xhGB%xnC", 2)).to eq "A%xc%xhG%xnC"
      end
      
      it "should pad if the string is too short" do
        expect(SubstitutionFormatter.center("A%xc%xhGB%xnC", 10, ".")).to eq "...A%xc%xhGB%xnC..."
      end
    end      

    describe :left do
      it "should truncate if the string is too long" do
        expect(SubstitutionFormatter.left("A%xc%xhGB%xnC", 2)).to eq "A%xc%xhG%xnC"
      end
      
      it "should pad if the string is too short" do
        expect(SubstitutionFormatter.left("A%xc%xhGB%xnC", 10, ".")).to eq "A%xc%xhGB%xnC......"
      end
      
      it "should pad if the string is just right" do
        expect(SubstitutionFormatter.left("%xrABC%xn", 3)).to eq "%xrABC%xn"
      end
    end 

    describe :right do
      it "should truncate if the string is too long" do
        expect(SubstitutionFormatter.right("A%xc%xhGB%xnC", 2)).to eq "A%xc%xhG%xnC"
      end
      
      it "should pad if the string is too short" do
        expect(SubstitutionFormatter.right("A%xc%xhGB%xnC", 10, ".")).to eq "......A%xc%xhGB%xnC"
      end
    end 
            
    describe :truncate do 
      it "should truncate a string that's too long" do
        expect(SubstitutionFormatter.truncate("A%xc%xhGB%xnC", 2)).to eq "A%xc%xhG%xnC"
      end
      
      it "should do nothing for a string that's shorter than allowed" do
        expect(SubstitutionFormatter.truncate("A%xc%xhGB%xnC", 20)).to eq "A%xc%xhGB%xnC"
      end
    end
    
  end
end
