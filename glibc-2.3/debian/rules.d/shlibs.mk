shlib_depend = $(libc) (>= 2.3-1)

debian/libc/DEBIAN/shlibs: debian/rules.d/shlibs.mk $(DEB_HOST_GNU_TYPE)
	(cat $(objdir)/soversions.i | while read lib so_ver sym_ver; do \
	    case $$lib in \
		ld) \
		    line=`echo $$so_ver | awk -F. '{print $$1 " " $$3}'`; \
		    echo "/lib/$$line $(shlib_depend)"; \
		    echo "$$line $(shlib_depend)";; \
		*) echo "$$lib $$so_ver $(shlib_depend)";; \
	    esac; \
	done;) > $@; exit 0
	chmod 0644 $@
