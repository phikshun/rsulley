module RSulley

class Graph
  attr_accessor :id, :clusters, :edges, :nodes
  
  def initialize(id = nil)
    @id       = id
    @clusters = []
    @edges    = {}
    @nodes    = {}
  end
  
  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end
  
  def add_cluster(cluster)
    @clusters << cluster
    self
  end
  
  def add_edge(edge, prevent_dups = true)
    if prevent_dups
      return self if @edges[edge.id]
    end
    
    @edges[edge.id] = edge if find_node(:id, edge.src) && find_node(:id, edge.dst)
    self
  end
  
  def add_graph(other_graph)
    graph_cat(other_graph)
  end
  
  def add_node(node)
    node.number = @nodes.count
    
    @nodes[node.id] = node unless @nodes[node.id]
    self
  end
  
  def del_cluster(id)
    @clusters.each do |cluster|
      if cluster.id == id
        @clusters = @clusters - cluster
        break
      end
    end
    self
  end
  
  def del_edge(opts)
    # Remove an edge from the graph. There are two ways to call this routine, with an edge id::
    #
    #    del_edge(id)
    #
    # or by specifying the edge source and destination::
    #
    #    del_edge(:src => source, :dst => destination)
    
    if opts.is_a? Hash
      src = opts[:src]
      dst = opts[:dst]
      id  = 0
    else
      src = nil
      dst = nil
      id  = opts
    end
    
    id = (src << 32) + dst unless id
    
    @edges.delete(id) if @edges[id]
    self
  end
  
  def del_graph(other_graph)
    graph_sub(other_graph)
  end
  
  def del_node(id)
    @nodes.delete(id) if @nodes[id]
    self
  end
  
  def edges_from(id)
    @edges.each_value.inject([]) { |result, edge| result << edge if edge.src == id; result }
  end
  
  def edges_to(id)
    @edges.each_value.inject([]) { |result, edge| result << edge if edge.dst == id; result }
  end
  
  def find_cluster(attribute, value)
    @clusters.each do |cluster|
      return cluster if cluster.respond_to?(attribute.to_sym) && cluster.send(attribute.to_sym) == value
    end
    nil
  end
  
  def find_cluster_by_node(attribute, value)
    @clusters.each do |cluster|
      cluster.each do |node|
        return cluster if node.respond_to?(attribute.to_sym) && node.send(attribute.to_sym) == value
      end
    end
    nil
  end
  
  def find_edge(attribute, value)
    return @edges[value] if attribute.to_sym == :id && @edges[value]
    
    @edges.each_value do |edge|
      return edge if edge.respond_to?(attribute.to_sym) && edge.send(attribute.to_sym) == value
    end
    nil
  end
  
  def find_node(attribute, value)
    return @nodes[value] if attribute.to_sym == :id && @nodes[value]
    
    @nodes.each_value do |node|
      return node if node.respond_to?(attribute.to_sym) && node.send(attribute.to_sym) == value
    end
    nil
  end
  
  def graph_cat(other_graph)
    other_graph.nodes.each_value { |other_node| add_node other_node }
    other_graph.edges.each_value { |other_edge| add_edge other_edge }
    self
  end
  
  def graph_down(from_node_id, max_depth = -1)
    down_graph = Graph.new
    from_node  = find_node(:id, from_node_id)
    
    raise "unabled to resolve node %08x" % from_node_id unless from_node_id
    
    levels_to_process = []
    current_depth     = 1
    
    levels_to_process << [from_node]
    
    levels_to_process.each do |level|
      next_level = []
      
      break if current_depth > max_depth && max_depth != -1
      
      level.each do |node|
        down_graph.add_node(deep_copy node)
        
        edges_from(node.id).each do |edge|
          to_add = find_node(:id, edge.dst)
          
          next_level << to_add unless down_graph.find_node(:id, edge.dst)
          
          down_graph.add_node(deep_copy to_add)
          down_graph.add_node(deep_copy edge)
        end
      end
      
      levels_to_process << next_level unless next_level.empty?
      current_depth += 1
    end
    
    down_graph    
  end
  
  def graph_intersect(other_graph)
    @nodes.each_value do |node|
      del_node(node.id) unless other_graph.find_node(:id, node.id)
    end
    
    @edges.each_value do |edge|
      del_edge(edge.id) unless other_graph.find_edge(:id, edge.id)
    end
    self
  end
  
  def graph_proximity(center_node_id, opts = {})
    max_depth_up    = opts[:max_depth_up]   || 2
    max_depth_down  = opts[:max_depth_down] || 2
    
    prox_graph = graph_down(center_node_id, max_depth_down)
    prox_graph.add_graph(graph_up center_node_id, max_depth_up)
  end
  
  def graph_sub(other_graph)
    other_graph.nodes.each_value { |other_node| del_node other_node.id  }
    other_graph.edges.each_value { |other_edge| del_node other_edge.dst }
    self
  end
  
  def graph_up(from_node_id, max_depth = -1)
    up_graph  = Graph.new
    from_node = find_node(:id, from_node_id)
    
    levels_to_process = []
    current_depth     = 1
    
    levels_to_process << [from_node]
    
    levels_to_process.each do |level|
      next_level = []
      
      break if current_depth > max_depth && max_depth != -1
      
      level.each do |node|
        up_graph.add_node(deep_copy node)
        
        edges_to(node.id).each do |edge|
          to_add = find_node(:id, edge.src)
          
          next_level << to_add unless up_graph.find_node(:id, edge.src)
          
          up_graph.add_node(deep_copy to_add)
          up_graph.add_edge(deep_copy edge)
        end
      end
      
      levels_to_process << next_level unless next_level.empty?
      current_depth += 1
    end
    
    up_graph
  end
  
  def render_graph_gml
    gml  = "Creator \"rGraph (port of pGraph - Pedram Amini)\"\n"
    gml += "directed 1\n"
    
    gml += "graph [\n"
    
    @nodes.each_value { |node| gml += node.render_node_gml(self) }
    @edges.each_value { |edge| gml += edge.render_edge_gml(self) }
    
    gml += "]\n"
  end
  
  def render_graph_graphviz
    # TODO - Find Ruby Graphviz library
    raise NotImplementedError
  end
  
  def render_graph_udraw
    udraw = '['
    
    @nodes.each_value do |node|
      udraw += node.render_node_udraw(self)
      udraw += ','
    end
    
    udraw = udraw[0..-2] + ']'
  end
  
  def render_graph_udraw_update
    udraw = '['
    
    @nodes.each_value do |node|
      udraw += node.render_node_udraw(self)
      udraw += ','
    end
    
    @edges.each_value do |edge|
      udraw += edge.render_edge_udraw(self)
      udraw += ','
    end
    
    udraw = udraw[0..-2] + ']'
  end
  
  def update_node_id(current_id, new_id)
    return unless @nodes[current_id]
    
    node = @nodes[current_id]
    @nodes.delete current_id
    node.id = new_id
    @nodes[node.id] = node
    
    @edges.each_value.inject([]) do |result, edge|
      result << edge if [e.src, e.dst].include? current_id
      result
    end.each_value do |edge|
      @edges.delete edge.id
      
      edge.src = new_id if edge.src == current_id
      edge.dst = new_id if edge.dst == current_id
      
      edge.id = (edge.src << 32) + edge.dst
      @edges[edge.id] = edge
    end
  end
  
  def sorted_nodes
    node_keys = @nodes.keys
    node_keys.sort!
    
    node_keys.map { |key| @nodes[key] }
  end
end

end
