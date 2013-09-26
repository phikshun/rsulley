module RSulley
  
class Cluster
  attr_accessor :id, :nodes
  
  def initialize(id = nil)
    @id    = id
    @nodes = []
  end
  
  def add_node(node)
    @nodes << node
    self
  end
  
  def del_node(node_id)
    @nodes.each do |node|
      if node.id == node_id
        @nodes = @nodes - node
        break
      end
    end
    self
  end
  
  def find_node(attribute, value)
    @nodes.each do |node|
      if node.respond_to?(attribute.to_sym)
        return node if node.send(attribute.to_sym) == value
      end
    end
    nil
  end
  
  def render
  end
end

end
        