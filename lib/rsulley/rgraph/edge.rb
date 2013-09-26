module RSulley
  
class Edge
  attr_accessor :id, :src, :dst, :color, :label, :gml_arrow, :gml_stipple, :gml_line_width
  
  def initialize(src, dst)
    @id  = (src << 32) + dst
    @src = src
    @dst = dst
    
    @color = 0x000000
    @label = ""
    
    @gml_arrow      = "none"
    @gml_stipple    = 1
    @gml_line_width = 1.0
  end
  
  def render_edge_gml(graph)
    s = graph.find_node(:id, @src)
    d = graph.find_node(:id, @dst)
    
    return '' if !s || !d
    
    edge  = "  edge [\n"
    edge += "    source \n"           % s.number
    edge += "    target %d\n"         % d.number
    edge += "    generalization 0\n"
    edge += "    graphics [\n"
    edge += "      type \"line\"\n"
    edge += "      arrow \"%s\"\n"    % @gml_arrow
    edge += "      stipple %d\n"      % @gml_stipple
    edge += "      lineWidth %f\n"    % @gml_line_width
    edge += "      fill \"#%06x\"\n"  % @color
    edge += "    ]\n"
    edge += "  ]\n"
  end
  
  def render_edge_graphviz(graph)
    # TODO: need Ruby GraphViz gem
    raise NotImplementedError
  end
  
  def render_edge_udraw(graph)
    s = graph.find_node(:id, @src)
    d = graph.find_node(:id, @dst)
    
    return '' if !s || !d
    
    @label = @label.to_s.gsub("\n", "\\n")
    
    udraw  = "l(\"%08x->%08x\","                  % [@src, @dst]
    udraw +=   "e(\"\","                          # open edge
    udraw +=     "["                              # open attributes
    udraw +=       "a(\"EDGECOLOR\",\"#%06x\"),"  % @color
    udraw +=       "a(\"OBJECT\",\"%s\")"         % @label
    udraw +=     "],"                             # close attributes
    udraw +=     "r(\"%08x\")"                    % @dst
    udraw +=   ")"                                # close edge
    udraw += ")"                                  # close element
  end
  
  def render_edge_udraw_update
    @label = @label.to_s.gsub("\n", "\\n")
    
    udraw  = "new_edge(\"%08x->%08x\",\"\","      % [@src, @dst]
    udraw +=   "["
    udraw +=     "a(\"EDGECOLOR\",\"#%06x\"),"    % @color
    udraw +=       "a(\"OBJECT\",\"%s\")"         % @label
    udraw +=   "],"
    udraw +=   "\"%08x\",\"%08x\""                % [@src, @dst]
    udraw += ")"
  end
end

end
