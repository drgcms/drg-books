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

########################################################################
#
########################################################################
class DcBookRenderer < DcRenderer
include DcApplicationHelper

#########################################################################
# List all books
########################################################################
def list
  html = ''
  if @opts[:edit_mode] > 1
    html << dc_link_for_create({ controller: 'cmsedit', table: 'dc_book', title: t('dc_book.new_book') }) 
  end
  books = DcBook.where(active: true).sort(title: 1).to_a
  html << @parent.render( partial: 'dc_book/list', locals: { books: books }, formats: [:html] )
end

#########################################################################
# Table of contents
########################################################################
def toc
  html = ''
  if @opts[:edit_mode] > 1
    dc_add2_record_cookie( { "dc_book_chapter.dc_book_id" => @parent.params[:book_id] } )
    html << dc_link_for_create({ controller: 'cmsedit', table: 'dc_book_chapter', title: t('dc_book.new_chapter') }) 
  end
  book = DcBook.find_by(link: @parent.params[:book_id])
  chapters = DcBookChapter.where(dc_book_id: book._id, active: true).sort(chapter: 1).to_a
  html << @parent.render( partial: 'dc_book/toc', locals: { chapters: chapters, book: book }, formats: [:html] )
end

#########################################################################
# chapter
########################################################################
def chapter
  html = ''
#  texts   = DcBookChapter.where(_id: @parent.params[:book_id], active: true).sort(chapter: 1).to_a
  book    = DcBook.find_by(link: @parent.params[:book_id])
  chapter = DcBookChapter.find_by(dc_book_id: book.id, link: @parent.params[:chapter_id])
  if chapter
    prev_chapter = DcBookChapter.where(dc_book_id: book._id, :chapter.lt => chapter.chapter)
                                .order_by(chapter: -1).limit(1).first
    next_chapter = DcBookChapter.where(dc_book_id: book._id, :chapter.gt => chapter.chapter).limit(1).first
  else
    prev_chapter, next_chapter = nil, nil 
  end
#  
  if @opts[:edit_mode] > 1
    html << dc_link_for_create({ controller: 'cmsedit', table: 'dc_book_chapter;dc_book_text', ids: chapter._id, title: t('dc_book.new_text') }) 
    dc_add2_record_cookie( { "dc_book_text.author" => chapter.author } ) if chapter
  end
#   
  if chapter
    texts = chapter.dc_book_texts.where(active: true).to_a
    if texts.size > 0
      replies = chapter.dc_replies.where(active: true).order(created_at: 1).
                page(@parent.params[:page]).per(20)      
      versions = texts.inject([]) {|r,e| r << [e.version, e._id] }
# display specific version when text_id is specified      
      text = @parent.params[:text_id] ? chapter.dc_book_texts.find(@parent.params[:text_id]) : texts.last
      html << @parent.render( partial: 'dc_book/chapter', 
                              locals: { chapter: chapter, replies: replies, text: text, versions: versions, 
                              prev_chapter: prev_chapter, next_chapter: next_chapter}, 
                              formats: [:html] )
    end
  end
  html
end

#########################################################################
# render html
########################################################################
def render_html
  method = @parent.params[:method] || 'list'
  respond_to?(method) ? send(method) : "Error DcBook: Method #{method} doesn't exist!"
end

end
