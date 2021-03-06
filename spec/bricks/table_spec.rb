require "spec_helper"

describe Bricks::Table do
  before(:each) do
    @data = [
        [ 1, "lucas", "lucas@vera.com"],
        [ 2, "tam", "tam@vera.com"]
      ]
    @options = { :header => %w(id name email) }
  end
  
  it "should be initializable with no arguments" do
    table = Bricks::Table.new
    table.should be_empty
    table.options.should == {}
  end
  
  context "being initialized" do
    
    it "should be initializable with and array of arrays" do
      table = Bricks::Table.new(@data)
      table.rows[0].should == @data[0]
    end
    
    it "should be able to receive only options, with no data" do
      table = Bricks::Table.new(@options)
      table.options.should == @options
    end
    
    it "should be able to receive data and options" do
      table = Bricks::Table.new(@data, @options)
      table.rows[0].should == @data[0]
      table.options.should == @options
    end
    
  end
  context "handling rows" do
    
    before do
      @row = [1, "Rolando", "rola@tony.com"]
      @table = Bricks::Table.new
      @table.add_row @row
    end
    
    it "should allow appending" do
      @table.should have(1).rows
    end
    
    it "should allow insertion" do
      new_row = [2, "jose", "jose@soprano.com"]
      @table.insert_row_at 0, new_row
      @table.rows[0].should == new_row
    end

    it "should allow deletion" do
      @table.insert_row_at 0, [2, "jose", "jose@soprano.com"]
      lambda {
         @table.delete_row_at 0
      }.should change(@table.rows, :size).by(-1)
    end
    
    it "should store Cell objects" do
      @table.rows.each do |row|
        row.each { |cell| cell.should be_a_kind_of(Bricks::Cell) }
      end
    end
    
    it "should keep the columns updated when adding rows"  do
      @table.columns.should have(3).elements
      @table.rows.should have(1).element
      @table.columns[0][0].should == @row[0]
      @table.columns[1][0].should == @row[1]
      @table.columns[2][0].should == @row[2]
    end
    
    it "should keep the columns updated when adding rows (many times)"  do
      lambda {
        lambda {
          @table.add_row [2, "Jose", "rola@cuac.com"]
        }.should_not change(@table.columns, :size)        
      }.should change(@table.rows, :size).by(1)
    end
    it "should support map and all the Enumerable operations" do
      @table.rows.each do |row|
        row[0] = 10000
        row[1] = "Joseph"
        row[2] = "por@onga.com"
      end
      @table.rows.each do |row|
        row[0].should == 10000
        row[1].should == "Joseph"
        row[2].should == "por@onga.com"
      end
    end
  end
  context "handling columns" do
    
    before do
      @column = [1, 2, 3]
      @table = Bricks::Table.new
      @table.add_column @column
    end
    
    it "should allow appending" do
      @table.should have(1).columns
      @table.columns.first.should == @column
    end
    
    it "should allow insertion" do
      new_column = ["juan", "pepe", "luis"]
      @table.insert_column_at 0, new_column
      @table.columns[0].should == new_column
    end
    
    it "should allow deletion" do
      lambda {
         @table.delete_column_at 0
      }.should change(@table.columns, :size).by(-1)
    end
    
    it "should store Cell objects" do
      @table.columns.each do |column|
        column.each { |cell| cell.should be_a_kind_of(Bricks::Cell) }
      end
    end
    
    it "should keep the columns updated when adding rows"  do
      @table.rows.should have(3).elements
      @table.rows[0][0].should == @column[0]
      @table.rows[1][0].should == @column[1]
      @table.rows[2][0].should == @column[2]
    end
    
    it "should keep the rows updated when adding columns (many times)"  do
      lambda {
        lambda {
          @table.add_column %w(mary john lucas)
        }.should change(@table.columns, :size).by(1)        
      }.should_not change(@table.rows, :size)
    end
    
  end
  context "when updating a cell from a column perspective" do
    
    it "should keep all the others perspectives updated (it should be the same cell)" do
      @column = [1, 2, 3]
      @table = Bricks::Table.new
      @table.add_column @column
      @table.rows[2][0].value = "NEW VALUE" # last row, first cell
      @table.columns[0][2].should == "NEW VALUE"
      @table.columns[0][2] === @table.rows[2][0]
    end
    
  end
  context "when defining column headers" do

    it "should allow to set the column name of a given column" do
      @table = Bricks::Table.new(@data)
      @table.columns.header['id'].index = 0
      @table.columns.header['Name'].index = 1
    end
    
    it "should set column names on initialization" do
      @table = Bricks::Table.new(@data, :header => %w(id Name Email))
      @table.columns.header['id'].index.should == 0
      @table.columns.header['Name'].index.should == 1
      @table.columns.header['Email'].index.should == 2
    end
  end
  context "accessing columns using their names" do
    before do
      @table = Bricks::Table.new(@data)
    end
    
    it "should allow you to get a given column by index" do
      @table.columns[1].should == ['lucas', 'tam']
    end
    
    it "should allow you to get a given column by name" do
      @table.columns.header['Nombre'].index = 1
      @table.columns['Nombre'].should == ['lucas', 'tam']
    end
  end
  it "should use first row as column header" do
    @data = [
      ["id", "name", "email"], 
      [1, "jose", "jose@soprano.com"]
    ]
    @table = Bricks::Table.new(@data, :first_row_as_header => true)
    @table.should have(1).rows
    @table.should have(3).columns
    @table.columns.header.keys.should == ["id", "name", "email"]
  end
end