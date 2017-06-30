class Biz::Md5Sign
  def self.get_mab(js)
    mab = []
    js.keys.sort_by {|x| x.downcase}.each do |k|
      mab << "#{k}=#{js[k].to_s}" if ![:mac, :sign, :controller, :action ].include?(k.to_sym) && js[k] && js[k].class != Hash
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
