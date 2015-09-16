module Apiway

  class Diff


    def initialize( source, target )
      @del, @add, @del_c, @add_c = {}, {}, 0, 0
      calculate source.to_s, target.to_s
    end

    def patch
      [ @del, @add ]
    end


    private

    def calculate( source, target )

      if found = find_middle( source, target )

        source_l, target_l, source, source_r, target_r = found
        calculate source_l, target_l
        @del_c += source.size
        @add_c += source.size
        calculate source_r, target_r

      else

        unless source.empty?
          @del[ @del_c ] = @del_c + source.size
        end

        unless target.empty?
          @add[ @add_c ] = target
          @add_c        += target.size
        end

      end

    end

    def find_middle( source, target, min = 0, max = nil )

      return nil if source.empty? || target.empty?

      max  = source.size unless max
      size = min + ( ( max - min ) / 2.to_f ).round

      subsets_each( source, size ) do |subset, first, last|

        if found = target.index( subset )

          return (
            size != min && find_middle( source, target, size, max ) ||
            (
              source_l = source[ 0...first ]
              target_l = target[ 0...found ]
              source_r = source[ last...source.size ]
              target_r = target[ found + subset.size...target.size ]
              [ source_l, target_l, subset, source_r, target_r ]
            )
          )

        end

      end

      size != max && find_middle( source, target, min, size ) || nil

    end

    def subsets_each( source, size )
      ( source.size - size + 1 ).times do |first|
        last     = first + size
        subset = source[ first...last ]
        yield subset, first, last
      end
    end


  end

end
