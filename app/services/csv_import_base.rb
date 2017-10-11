require 'smarter_csv'

class CSVImportBase
  attr_accessor :invalid_rows, :created_count, :skipped_count

  def initialize(file, quote_char = nil)
    @errors = []

    if file.blank?
      @errors << t('no_file')
    elsif file.respond_to?(:tempfile) && file.content_type == 'text/csv' && file.tempfile.respond_to?(:readline)
      @file = file.tempfile
    else
      @errors << t('invalid_file')
    end

    @quote_char = quote_char == "'" ? "'" : '"'
    @invalid_rows  = []
    @created_count = 0
    @skipped_count = 0
  end

  def invalid_count
    @invalid_rows.size
  end

  def valid_input?
    validate_header

    @errors.blank?
  end

  def run
    return self unless valid_input?

    begin
      SmarterCSV.process(@file, settings).each do |chunk|
        chunk.each do |params|
          begin
            process_row(params)
          rescue Exception => e
            p e.message
          end
        end
      end
    rescue Exception => e
      @errors << t('failed_to_process', error: e.message)
      print e.message
    end

    return self
  end

  def report_message
    if @errors.blank?
      t('report',
        created: created_count,
        skipped: skipped_count,
        failed: invalid_count)
    else
      @errors.join('; ')
    end
  end

  def self.csv_template
    CSV.generate(headers: true) do |csv|
      # header with columns
      csv << columns_legend.keys
      # example data row
      csv << columns_legend.values.map { |legend| legend[:placeholder] }
      # columns annotation
      csv << []
      csv << columns_legend.keys.map { |column| build_column_annotation(column) }
    end
  end

  protected

  def process_row(params)
    # subclass should implement actual creation of records here
    # increment corresponding counters: self.created_count, self.skipped_count
    # push failed rows into self.invalid_rows
    # rescue failed rows to make sensible errors for user in your invalid_rows format
  end

  def self.columns_legend
    {
      example_column_name: { placeholder: "Data example", required: true, comment: 'additional comment' }
    }
  end

  def self.build_column_annotation(column)
    legend = columns_legend[column]

    required = I18n.t("services.csv_import_base.#{ legend[:required] ? 'required' : 'non_required' }")
    comment = legend[:comment].present? ? ". #{legend[:comment]}" : ''

    "##{required}#{comment}"
  end

  def self.t(key, params = {})
    I18n.t("services.#{name.underscore}.#{key}", params.merge(default: dt(key, params)))
  end

  def self.dt(key, params = {})
    I18n.t("services.csv_import_base.#{key}", params)
  end

  def t(key, params = {})
    self.class.t(key, params)
  end

  def dt(key, params = {})
    self.class.dt(key, params)
  end

  def settings
    { quote_char: @quote_char,
      col_sep: ',',
      row_sep: $/,
      comment_regexp: /^#/,
      strip_whitespace: true,
      downcase_header: true,
      force_utf8: false,
      chunk_size: 1000,
      remove_unmapped_keys: true,
      key_mapping: self.class.columns_legend.map { |k,_| [k,k] }.to_h }
  end

  def read_header
    return if @errors.any?

    row = @file.readline.sub(settings[:comment_regexp],'').chomp(settings[:row_sep])
    @file.rewind

    begin
      header = CSV.parse(row, col_sep: settings[:col_sep], quote_char: settings[:quote_char], skip_blanks: true).first
      header.map { |c| c.to_s.gsub(%r/settings[:quote_char]/,'').strip.downcase.to_sym }
    rescue
      @errors << t('invalid_file')
      nil
    end
  end

  def validate_header
    header = read_header

    return if @errors.any?

    columns = self.class.columns_legend.keys
    missing_columns = []

    columns.each do |column|
      unless header.include?(column)
        missing_columns << column
      end
    end

    if missing_columns.any?
      @errors << t('invalid_header', missing: missing_columns.join(settings[:col_sep]))
    end
  end
end
