CREATE TABLE audit(
        md5sum TEXT,            -- of FITS file
        obsday DATE,            -- observation day
        telescope TEXT not null, 
        instrument TEXT not null,
        srcpath TEXT not null,  -- full path of FITS file
        recorded DATETIME,      -- when srcpath was recorded by dome
        submitted DATETIME,     -- when submitted to archive 
        success BOOLEAN,        -- NULL until ingest attempted. Then True iff
                                -- archive reported success on ingest
        archerr TEXT,   -- Error message (if applicable) of Archive Ingest
        archfile TEXT,  -- basename of FITS file in Archive
        PRIMARY KEY (telescope, instrument, srcpath)
        );
