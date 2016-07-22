class Logjoin

  #  log = Logjoin.new('joined.log', '.*, \[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*#.*\]*.', "/Users/rafaelbiriba/logs-eventos-29maio/old/riomp89-production-2014052718.log", "/Users/rafaelbiriba/logs-eventos-29maio/old/riomp89-production-2014052706.log", "/Users/rafaelbiriba/logs-eventos-29maio/old/riomp90-production-2014052718.log", "/Users/rafaelbiriba/logs-eventos-29maio/old/riomp90-production-2014052706.log")

  #   log = Logjoin.new('teste', '.*, \[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*#.*\]*.', "/Users/rafaelbiriba/logs-eventos-29maio/old/riomp89-production-2014052706.log")


  #   log = Logjoin.new('teste', '.*, \[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*#.*\]*.', "spec/fixtures/log1.log", "spec/fixtures/log2.log")

  def initialize export_file, date_regexp, *log_files
    @export_file = File.expand_path(export_file)
    @date_regexp = date_regexp
    @log_files = log_files
    @log_lines = []
  end

  def run
    prepare_logfiles
    check_logfiles
    extract_logfiles
    validate_date_parse
    prepare_loglines
    sort_loglines
    export_generated_logfile
    true
  rescue StandardError => e
    puts e.message
  end

  def logs
    @log_lines
  end

  private
  def prepare_logfiles
    @log_files.map!{ |file| File.expand_path(file) }
  end

  def check_logfiles
    @log_files.each do |file|
      raise "File #{file} not found!" unless File.exists?(file)
    end
  end

  def check_loglines
    raise "Nothing to join" if @log_lines.empty?
  end

  def validate_date_parse
    raise "Date Regexp empty" unless @date_regexp
    date = date_regexp_match @log_lines.first[:content]
    raise "No dates found in the first line of log using the given regexp #{@date_regexp}" unless date
    DateTime.parse(date)
  rescue StandardError => e
      raise "Validate date parser error: #{e.message}"
  end

  def prepare_loglines
    log_lines = @log_lines.reverse

    log_lines = log_lines.each_with_index do |log, index|
      date = date_regexp_match(log[:content]).strip
      if date.empty?
        log_lines[index+1][:content] << "\n#{log[:content]}"
        log[:delete] = true
      else
        date = DateTime.parse(date).to_time.to_i
        log[:date] = date
      end
    end

    log_lines.delete_if { |line| line[:delete] }

    @log_lines = log_lines.reverse
  end

  def extract_logfiles
    @log_files.each do |file|
      IO.foreach(file) do |line|
        line = line.strip
        @log_lines << { content: line } unless line.empty?
      end
    end
  end

  def sort_loglines
    @log_lines = @log_lines.sort_by{ |a| a[:date] }
  end

  def export_generated_logfile
    File.open(@export_file, 'w') do |f|
      @log_lines.each do |line|
        f.puts line[:content]
      end
    end
  end

  def date_regexp_match line
    date = Regexp.new(@date_regexp).match(line)
    date = [] unless date
    date[1].to_s
  rescue RegexpError => e
      raise "Invalid Regexp: #{e.message}"
  end
end
