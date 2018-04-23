class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
                DROP TABLE IF EXiSTS dogs
            SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id != nil
            self
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES(?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    def self.create(name: , breed:)
        new_dog = self.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        found = DB[:conn].execute(sql, id).flatten
        new_dog = self.new(id: found[0],name: found[1], breed: found[2])
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        sql =  <<-SQL
            SELECT * FROM dogs WHERE name = ? and breed = ?;
        SQL
        found = DB[:conn].execute(sql, name, breed)
        if found.empty?
            self.create(name, breed)
        else
            dog = found.flatten
            self.new_from_db(dog)
            # found.each do |dog|
            #     binding.pry
            #     if dog[1] == name && dog[2] == breed
            #         binding.pry
            #         d = dog.flatten
            #         self.new_from_db(d)
            #         binding.pry
            #     end

        end
    end

    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1],breed: row[2])
        new_dog.save
    end


end
