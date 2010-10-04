Coal.module 'Digest' do
  # This is a working implementation of MurmurHash2.
  # Original code at: http://sites.google.com/site/murmurhash/MurmurHash2.cpp
  function 'murmurhash2', [:pointer, :uintn, :uint32], :uint32, <<-'end'
    @uint8 data = arg(0)
    uintn len = arg(1)
    uint32 seed = arg(2)
    
    uint32 m = 0x5bd1e995
    int32 r = 24
    
    uint32 h = seed ^ len
    
    while(len >= 4)
    {
      uint32 k = *data:uint32

      k *= m
      k ^= k >> r
      k *= m
    
      h *= m
      h ^= k

      data += 4
      len -= 4
    }
    
    if(len > 0)
    {
      uint32 k = *data:uint32
      if(len == 3) h ^= k & 0xff0000
      if(len >= 2) h ^= k & 0x00ff00
      h ^= k & 0x0000ff
      h *= m
    }

    h ^= h >> 13
    h *= m
    h ^= h >> 15

    return(h)
  end
end

