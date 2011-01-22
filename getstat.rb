require 'net/http'
require 'json'

class Site
	def initialize(host, page_template, tokens, range)
		@host = host
		@page_template = page_template
		@tokens = tokens
		@range = range
	end

	def getCompaniesFromPage(uri)
		resource = Net::HTTP.new(@host, 80)
		headers, data = resource.get(uri)

		pattern = /#{@tokens['id']}.*?#{@tokens['before']}(.*?)#{@tokens['after']}/x
		companies = Array.new
		data.scan(pattern) {
			companies.push($1.strip.force_encoding("UTF-8"))
		}
		return companies
	end

	def getAllCompanies
		companies = Array.new
		@range.each do |page|
			getCompaniesFromPage(sprintf(@page_template, page)).each { |c|
				companies.push(c)
			}
		end
		return companies
	end

	def getStatsArray
		stats = Hash.new(0)
		getAllCompanies.each do |c|
			stats["#{c}"] += 1
		end
		return stats
	end

	def getStatsJSON
		return getStatsArray.to_json
	end
end	

erabota_tokens = {
	'id' => 'src="\/img\/icons\/icon-link\.gif"',
	'before' => 'a>',
	'after' => ', '
}
erabota = Site.new("nsk.erabota.ru", "/job/it/?page=%d", erabota_tokens, (1..17))

ngs_tokens = {
	'id' => 'class="saler"',
	'before' => '>',
	'after' => '<'
}
ngs = Site.new("rabota.ngs.ru", "/vacancies/search/?pageType=search&rubrics[]=5&other2=yes&page=%d", ngs_tokens, (1..21))

hh_tokens = {
	'id' => 'class="b-vacancy-list-company"',
	'before' => '>',
	'after' => '<'
}
hh = Site.new("novosibirsk.hh.ru", "http://novosibirsk.hh.ru/applicant/searchvacancyresult.xml?orderBy=2&itemsOnPage=20&areaId=4&professionalAreaId=1&compensationCurrencyCode=RUR&searchPeriod=30&page=%d", hh_tokens, (0..10))

puts erabota.getStatsJSON
puts ngs.getStatsJSON
puts hh.getStatsJSON
