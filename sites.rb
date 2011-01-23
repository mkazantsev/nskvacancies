require 'net/http'
require 'uri'
require 'json'

module Sites
	class Site
		def initialize(url_template, tokens, range)
			@url_template = url_template
			@tokens = tokens
			@range = range
		end
	
		def getCompaniesFromPage(url_text)
			url = URI.parse(url_text)
			resource = Net::HTTP.new(url.host, url.port)
			headers, data = resource.get(url.to_s)

			pattern = /#{@tokens['id']}.*?#{@tokens['before']}(.*?)#{@tokens['after']}/x
			encoding = headers['content-type'].split('=')[1]

			companies = Array.new
			data.scan(pattern) {
				companies.push($1.strip.encode!("UTF-8", encoding))
			}
			return companies
		end
	
		def getAllCompanies
			companies = Array.new
			@range.each do |page|
				getCompaniesFromPage(sprintf(@url_template, page)).each { |c|
					companies.push(c)
				}
			end
			return companies
		end
	
		def getStatsHash
			stats = Hash.new(0)
			getAllCompanies.each do |c|
				stats["#{c}"] += 1
			end
			return stats
		end
	
		def getStatsJSON
			return getStatsHash.to_json
		end
	end	
	
	erabota_tokens = {
		'id' => 'src="\/img\/icons\/icon-link\.gif"',
		'before' => 'a>',
		'after' => ', '
	}
	Erabota = Site.new("http://nsk.erabota.ru/job/it/?page=%d", erabota_tokens, (1..17))
	
	ngs_tokens = {
		'id' => 'class="saler"',
		'before' => '>',
		'after' => '<'
	}
	Ngs = Site.new("http://rabota.ngs.ru/vacancies/search/?pageType=search&rubrics[]=5&other2=yes&page=%d", ngs_tokens, (1..21))
	
	hh_tokens = {
		'id' => 'class="b-vacancy-list-company"',
		'before' => '>',
		'after' => '<'
	}
	Hh = Site.new("http://novosibirsk.hh.ru/applicant/searchvacancyresult.xml?orderBy=2&itemsOnPage=20&areaId=4&professionalAreaId=1&compensationCurrencyCode=RUR&searchPeriod=30&page=%d", hh_tokens, (0..10))
end
