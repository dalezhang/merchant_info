class Biz::Md5Sign
  def self.get_mab(js)
    mab = []
    js.deep_symbolize_keys
    sign_js = {}
    js.each do |k, v|
      if v.present?
        sign_js[k] = v
      end
    end
    sign_js.keys.sort_by {|x| x.downcase}.each do |k|
      mab << "#{k}=#{js[k].to_s}" if ![:mac, :sign, :controller, :action ].include?(k.to_sym) && js[k].present? && js[k].class != Hash
    end
    mab.join('&')
  end

  def self.md5(str)
    Digest::MD5.hexdigest(str)
  end
  def self.get_mac(js, key)
    md5(get_mab(js) + "&key=#{key}").upcase
  end
end
