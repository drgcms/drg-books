#--
# Copyright (c) 2013+ Damjan Rems
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

######################################################################
# == Schema information
#
# Collection name: dc_book : Books
#
#  _id                  BSON::ObjectId       _id
#  created_at           Time                 created_at
#  updated_at           Time                 updated_at
#  title                String               Book title
#  link                 String               link
#  description          String               Short description of the book
#  active               Mongoid::Boolean     Active
#  author               String               Author's name
#  created_by           BSON::ObjectId       created_by
#  updated_by           BSON::ObjectId       updated_by
######################################################################
class DcBook
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :title,       type: String
  field :link,        type: String
  field :description, type: String
  field :active,      type: Boolean, default: true
  field :author,      type: String
  field :link,        type: String

  field :created_by,  type: BSON::ObjectId
  field :updated_by,  type: BSON::ObjectId
  
  validates :title,   presence: true  
  validates :description,   presence: true  

  index link: 1

before_save :do_before_save

######################################################################
# Clears subject link of chars that shouldn't be there and also take care of its size
######################################################################
def clear_link(link)
  link.gsub!(/\.|\?|\!\&|»|«|\,|\"|\'|\:/,'')
  link.gsub!('<br>','')
  link.gsub!(' ','-')
  link.gsub!('---','-')
  link.gsub!('--','-')
  link
end

######################################################################
def do_before_save
  if self.link.empty?
    self.link = clear_link(self.title.downcase.strip)
  end
end
  
end
