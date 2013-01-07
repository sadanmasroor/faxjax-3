module TagHelper
  def _tag_start qname, attrs={}
    "<#{qname}" +
      (attrs.empty? ? '' : " " + attrs.map {|k,v| "#{k}=\"#{v}\""}.join(" "))
  end

  def _tag_end qname
    "</#{qname}>"
  end

  def _tga(qname, attrs={}, &blk)
    _tag_start(qname, attrs) + (block_given? ? (">" + yield + _tag_end(qname)) : " />" )
  end
  
  def _tg(name, attrs=nil, &blk)
    "<#{name}" +
    (attrs.nil? ? "" : " " + attrs) +
    ">" +
    (block_given? ? yield : "") +
    "</#{name}>"
  end

  def hidden name, value
    options = {:type => 'hidden'}
    options[:name] = name
    options[:value] = value
    _tga(:input, options)
  end

  #  simple block tag maker ala builde
  def div(id=nil, &blk)
    _tg('div', "id=\"#{id}\"", &blk)
  end

  def li(attrs=nil, &blk)
    _tg('li', attrs, &blk)
  end
  
  def para(attrs=nil, &blk)
    _tg("p", attrs, &blk)
  end

  def strong(attrs=nil, &blk)
    _tg("strong", attrs, &blk)
  end
  
  def h4(attrs=nil, &blk)
    _tg("h4", attrs, &blk)
  end
  
  def mailto(email)
    _tg('a', 'href="mailto:'+email+'"') {email}
  end

  def tr options={}, &blk
    _tga :tr, options, &blk
  end
  
  def td options={}, &blk
    _tga :td, options, &blk
  end

  def input options
    _tga :input, options
  end

  def _form options={}, str='',&blk
    options[:method] ||= 'post'
    if block_given?
      _tga :form, options, &blk 
    else
      _tga :form, options do
        str
      end
    end
  end

  #  to use take a hash.extend(TagHelper::HashHelper)
  module HashHelper
    include TagHelper
    
    def to_hiddens &blk
      result = []
      self.each do |key, value|
        value = yield value if block_given?
        result << hidden(key, value)
      end
      result.join("\n")
    end
  end
end

