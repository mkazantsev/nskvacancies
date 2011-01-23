load 'sites.rb'

require 'SVG/Graph/Pie'

def generateGraph(name, site)
	stats_array = site.getStatsHash.sort{|x, y| -1*(x[1] <=> y[1])}.take(10)

	stats = Hash.new
	stats_array.each { |k, v|
		stats[k] = v
	}

	graph = SVG::Graph::Pie.new({
		:height => 500,
		:widht => 300,
		:fields => stats.keys,
	})

	graph.add_data({
		:data => stats.values,
		:title => name,
	})

	return graph
end

print generateGraph("Erabota", Sites::Erabota).burn()
