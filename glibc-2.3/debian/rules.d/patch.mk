patch_dir := $(top_srcdir)debian/patches

setup: patch

patch: $(stamp_patch)
$(stamp_patch): $(stamp_unpack)
	if [ ! -d patched ]; then mkdir patched; fi
	@echo "Patches applied in the Debian version of the GNU C Library:" > $@T
	@while read patch; do \
		case $$patch in \#*) continue;; esac; \
		if [ -x $(patch_dir)/$$patch.dpatch ]; then true; else \
		  chmod +x $(patch_dir)/$$patch.dpatch; fi; \
		if [ -f $(top_srcdir)/patched/$$patch ]; then \
		  echo "$$patch already applied."; \
		  exit 1; \
		else \
		  echo "trying to apply patch $$patch ..."; \
		  if $(patch_dir)/$$patch.dpatch -patch $(srcdir) \
		  > $(top_srcdir)/patched/$$patch.new 2>&1; then \
		    mv $(top_srcdir)/patched/$$patch.new \
		       $(top_srcdir)/patched/$$patch; \
		    touch $(top_srcdir)/patched/$$patch; \
		    echo -e "\n$$patch:" >> $@T; \
		    sed -n 's/^# *DP: */  /p' $(patch_dir)/$$patch.dpatch \
		    >> $@T; \
		  else \
		    echo "error in applying $$patch patch."; \
		    exit 1; \
		  fi; \
		fi; \
	done < $(top_srcdir)debian/patches/0list
	mv -f $@T $@

unpatch:
	@tac $(top_srcdir)debian/patches/0list | \
	while read patch; do \
		case $$patch in \#*) continue;; esac; \
		if [ -x $(patch_dir)/$$patch.dpatch ]; then true; else \
		  chmod +x $(patch_dir)/$$patch.dpatch; fi; \
		if [ -f $(top_srcdir)/patched/$$patch ]; then \
		  echo "trying to revert patch $$patch ..."; \
		  if $(patch_dir)/$$patch.dpatch -unpatch $(srcdir);  then \
		    echo "reverted $$patch patch."; \
		    rm -f $(top_srcdir)/patched/$$patch; \
		  else \
		    echo "error in reverting $$patch patch."; \
		    exit 1; \
		  fi; \
		fi; \
	done
	rm -f $(stamp_patch)

