require_relative "../config/environment.rb"
require "pry"

class Dog

attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "

    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed BREED
    );
    "

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    hash = {
    id: row[0],
    name: row[1],
    breed: row[2]
  }
    self.new(hash)
  end

  def self.find_by_name(name)
    sql = "
    SELECT id, name, breed
    FROM dogs
    WHERE name = ?
    "
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def save
    if self.id
      self.update
    else
      sql = "
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      "
      DB[:conn].execute(sql, self.name, self.breed)
    end
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
  end

  def update
    sql = "
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
    "
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name)
    dog = Dog.new(name)
    dog.save
  end

  def self.find_by_id(id)
    sql = "
    SELECT id, name, breed
    FROM dogs
    WHERE id = ?
    "
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      hash = {
      id: dog_data[0],
      name: dog_data[1],
      breed: dog_data[2]
    }
      dog = Dog.new(hash)
    else
      dog = self.create(name:name, breed: breed)
    end
    dog
  end

end
