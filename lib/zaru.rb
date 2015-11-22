# encoding: utf-8
class Zaru
  CHARACTER_FILTER = /[\p{Cntrl}\[\]\{\}\|\/\\`!@$*()<>?'";:]/u
  UNICODE_WHITESPACE = /[[:space:]]+/u
  WINDOWS_RESERVED_NAMES =
    %w{CON PRN AUX NUL COM1 COM2 COM3 COM4 COM5
       COM6 COM7 COM8 COM9 LPT1 LPT2 LPT3 LPT4
       LPT5 LPT6 LPT7 LPT8 LPT9}
  FALLBACK_FILENAME = 'file'

  def initialize(filename, options={})
    @padding = options[:padding] || 0
    @length = options[:length] || 255
    @whitespace = options[:whitespace] || ' '
    @replacement_char = options[:replace] || ''
    @raw = filename.to_s.freeze
  end

  # strip whitespace on beginning and end
  # collapse intra-string whitespace into single spaces
  def normalize
    @raw.strip.gsub(UNICODE_WHITESPACE, @whitespace)
  end

  # remove bad things!
  # - remove characters that aren't allowed cross-OS
  # - don't allow certain special filenames (issue on Windows)
  # - don't allow filenames to start with a dot
  # - don't allow empty filenames
  def sanitize
    filter(normalize)
  end

  # cut off at 255 characters
  # optionally provide a padding, which is useful to
  # make sure there is room to add a file extension later
  def truncate
    sanitize.slice(0, @length-@padding)
  end

  def to_s
    truncate
  end

  # convenience method
  def self.sanitize!(filename, options={})
    new(filename, options).to_s
  end

  private

    def filter(filename)
      filename = filter_characters(filename)
      filename = filter_windows_reserved_names(filename)
      filename = filter_blank(filename)
      filename = filter_start(filename)
    end

    def filter_characters(filename)
      filename.gsub(CHARACTER_FILTER, @replacement_char)
    end

    def filter_windows_reserved_names(filename)
      WINDOWS_RESERVED_NAMES.include?(filename.upcase) ? FALLBACK_FILENAME : filename
    end

    def filter_blank(filename)
      filename.empty? ? FALLBACK_FILENAME : filename
    end

    def filter_start(filename)
      filename.sub(/^(-[[:space:]]?)+/u, '')
    end

end
