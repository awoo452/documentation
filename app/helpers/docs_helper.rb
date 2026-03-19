# frozen_string_literal: true

require "cgi"
require "openssl"

module DocsHelper
  YOUTUBE_ID_REGEX = %r{
    (?:youtu\.be/|youtube\.com/(?:watch\?v=|embed/|shorts/))
    ([\w-]{11})
  }x.freeze

  def docs_image_src(image)
    key = docs_media_key(image)
    if key.present?
      proxy_url = docs_image_proxy_url(image, key: key)
      return proxy_url if proxy_url.present?
    end

    src = extract_media_value(image, %w[src url]).to_s.strip
    return image_path("logo.png") if src.blank?

    return src if src.start_with?("http://", "https://", "//", "/")

    image_path(src)
  end

  def docs_image_alt(image, index)
    alt = extract_media_value(image, %w[alt]).to_s.strip
    alt.presence || "Doc image #{index}"
  end

  def docs_image_caption(image)
    extract_media_value(image, %w[caption]).to_s.strip.presence
  end

  def docs_youtube_embed_url(video)
    url = extract_media_value(video, %w[url src]).to_s.strip
    return if url.blank?

    match = url.match(YOUTUBE_ID_REGEX)
    return unless match

    "https://www.youtube.com/embed/#{match[1]}"
  end

  def docs_video_caption(video)
    extract_media_value(video, %w[caption]).to_s.strip.presence
  end

  private

  def extract_media_value(value, keys)
    return value if value.is_a?(String)
    return "" unless value.is_a?(Hash)

    keys.each do |key|
      return value[key] if value.key?(key)
      return value[key.to_sym] if value.key?(key.to_sym)
    end

    ""
  end

  def docs_media_key(value)
    key = extract_media_value(value, %w[key s3_key]).to_s.strip
    return key if key.present?

    src = extract_media_value(value, %w[src url]).to_s.strip
    return "" if src.blank?

    if src.start_with?("s3://")
      return src.delete_prefix("s3://").sub(%r{\A/+}, "")
    end

    if src.start_with?("s3:")
      return src.delete_prefix("s3:").sub(%r{\A/+}, "")
    end

    ""
  end

  def docs_image_proxy_url(image, key:)
    options = docs_image_proxy_options(image)
    width = options.fetch(:width, 1200)
    height = options[:height]
    fit = options[:fit]
    format = options.fetch(:format, "webp")
    auto_orient = options.fetch(:auto_orient, true)

    image_proxy_url(key, width: width, height: height, fit: fit, format: format, auto_orient: auto_orient)
  end

  def docs_image_proxy_options(image)
    return {} unless image.is_a?(Hash)

    {
      width: image["width"] || image[:width],
      height: image["height"] || image[:height],
      fit: image["fit"] || image[:fit],
      format: image["format"] || image[:format],
      auto_orient: image.key?("auto_orient") ? image["auto_orient"] : image[:auto_orient]
    }.compact
  end

  def image_proxy_url(key, width:, height: nil, fit: nil, format: nil, auto_orient: true)
    return if key.blank?

    base = ENV["IMAGE_PROXY_BASE_URL"]
    signing_key = ENV["IMAGE_PROXY_SIGNING_KEY"]
    bucket = ENV["AWS_BUCKET"]

    unless base.present? && signing_key.present? && bucket.present?
      begin
        return S3Service.new.presigned_url(key)
      rescue Aws::Errors::MissingCredentialsError, Aws::Errors::MissingRegionError
        return nil
      end
    end

    path_key = key.to_s.sub(%r{\A/}, "")
    path = "/#{path_key}"

    params = {
      width: width,
      height: height,
      fit: fit,
      format: format
    }.compact
    params[:rotate] = "" if auto_orient

    query = params
      .sort_by { |k, _| k.to_s }
      .map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }
      .join("&")

    signature_base = query.present? ? "#{path}?#{query}" : path
    signature = OpenSSL::HMAC.hexdigest("sha256", signing_key, signature_base)
    final_query = query.present? ? "#{query}&signature=#{signature}" : "signature=#{signature}"

    "#{base.chomp("/")}#{path}?#{final_query}"
  end
end
