# coding: binary

module RSulley
  
class Node
  attr_accessor :id, :number, :color, :border_color, :label, :shape,
                :gml_width, :gml_height, :gml_pattern, :gml_stipple,
                :gml_line_width, :gml_type, :gml_width_shape,
                :udraw_image, :udraw_info
  
  def initialize(id = nil)
    @id     = id
    @number = 0
    
    # general graph attributes
    @color        = 0xEEF7FF
    @border_color = 0xEEEEEE
    @label        = ""
    @shape        = "box"

    # gml relevant attributes.
    @gml_width       = 0.0
    @gml_height      = 0.0
    @gml_pattern     = "1"
    @gml_stipple     = 1
    @gml_line_width  = 1.0
    @gml_type        = "rectangle"
    @gml_width_shape = 1.0
  end
  
  def render_node_gml(graph)
    chunked_label = ''
    cursor        = 0
    
    while cursor < @label.length
      amount = 200
      
      if cursor + amount < @length.length
        while @label[cursor + amount] == "\\" || @label[cursor + amount] == "\"" do
          amount -= 1
        end
      end
      
      chunked_label += @label[cursor...(cursor + amount)] + "\\\n"
      cursor        += amount
    end
    
    @gml_width  = @label.length * 10 if !@gml_width
    @gml_height = @label.split  * 20 if !@gml_height
    
    node  = "  node [\n"
    node += "    id %d\n"                       % @number
    node += "    template \"oreas:std:rect\"\n"
    node += "    label \""
    node += "<!--%08x-->\\\n"                   % @id
    node += chunked_label + "\"\n"
    node += "    graphics [\n"
    node += "      w %f\n"                      % @gml_width
    node += "      h %f\n"                      % @gml_height
    node += "      fill \"#%06x\"\n"            % @color
    node += "      line \"#%06x\"\n"            % @border_color
    node += "      pattern \"%s\"\n"            % @gml_pattern
    node += "      stipple %d\n"                % @gml_stipple
    node += "      lineWidth %f\n"              % @gml_line_width
    node += "      type \"%s\"\n"               % @gml_type
    node += "      width %f\n"                  % @gml_width_shape
    node += "    ]\n"
    node += "  ]\n"
  end
  
  def render_node_graphviz(graph)
    # TODO: Need Ruby GraphViz library
    raise NotImplementedError
  end
  
  def render_node_udraw(graph)
    @label = @label.to_s.gsub("\n", "\\n")
    
    if @udraw_image
      @shape    = "image"
      udraw_img = "a(\"IMAGE\",\"%s\")," % @udraw_image
    else
      udraw_img = ''
    end
    
    udraw  = "l(\"%08x\","                          % @id
    udraw +=   "n(\"\","                            # open node
    udraw +=     "["                                # open attributes
    udraw +=       udraw_img
    udraw +=       "a(\"_GO\",\"%s\"),"             % @shape
    udraw +=       "a(\"COLOR\",\"#%06x\"),"        % @color
    udraw +=       "a(\"OBJECT\",\"%s\"),"          % @label
    udraw +=       "a(\"FONTFAMILY\",\"courier\"),"
    udraw +=       "a(\"INFO\",\"%s\"),"            % @udraw_info
    udraw +=       "a(\"BORDER\",\"none\")"
    udraw +=     "],"                               # close attributes
    udraw +=     "["                                # open edges
    
    udraw += graph.edges_from(@id).map do |edge|
      edge.render_edge_udraw(graph)
    end.join(",")
    
    udraw += "]))"
  end
  
  def render_node_udraw_update
    @label = @label.to_s.gsub("\n", "\\n")
    
    if @udraw_image
      @shape    = "image"
      udraw_img = "a(\"IMAGE\",\"%s\")," % @udraw_image
    else
      udraw_img = ''
    end
    
    udraw  =  "new_node(\"%08x\",\"\","            % @id
    udraw +=    "["                                # open attributes
    udraw +=      udraw_img
    udraw +=      "a(\"_GO\",\"%s\"),"             % @shape
    udraw +=      "a(\"COLOR\",\"#%06x\"),"        % @color
    udraw +=      "a(\"OBJECT\",\"%s\"),"          % @label
    udraw +=      "a(\"FONTFAMILY\",\"courier\"),"
    udraw +=      "a(\"INFO\",\"%s\"),"            % @udraw_info
    udraw +=      "a(\"BORDER\",\"none\")"
    udraw +=    "]"                               # close attributes
    udraw +=  ")"                                 # open edges
  end
end

end
