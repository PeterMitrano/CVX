function pop( prob, clearmode )
if nargin < 2, clearmode = 'clear'; end

%
% Determine the problem to be cleaned up
%

global cvx___
p = index( prob );
if p <= length( cvx___.problems ) & cvx___.problems( p ).self == prob,
    pid  = cvx_id( prob );
    prob = cvx___.problems( p );
    nf   = length( prob.t_variable ) + 1;
    ne   = prob.n_equality + 1;
    nl   = prob.n_linform + 1;
    nu   = prob.n_uniform + 1;
else
    p          = 1;
    pid        = -1;
    nf         = 0;
    ne         = 1;
    nl         = 1;
    nu         = 1;
    clearmode  = 'clear';
end

%
% Clear the corresponding and equality constraints and variables
%

if ~isequal( clearmode, 'none' ),
    if nf <= 2,
        cvx___.reserved    = 0;
        cvx___.geometric   = sparse( 1, 1 );
        cvx___.logarithm   = sparse( 1, 1 );
        cvx___.exponential = sparse( 1, 1 );
        cvx___.vexity      = 0;
        cvx___.canslack    = false;
        cvx___.readonly    = 0;
        cvx___.cones       = struct( 'type', {}, 'indices', {} );
    elseif length( cvx___.reserved ) >= nf,
        temp = nf : length( cvx___.reserved );
        cvx___.reserved(    temp, : ) = [];
        cvx___.geometric(   temp, : ) = [];
        cvx___.logarithm(   temp, : ) = [];
        cvx___.exponential( temp, : ) = [];
        cvx___.vexity(      temp, : ) = [];
        cvx___.canslack(    temp, : ) = [];
        cvx___.readonly(    temp, : ) = [];
        if ~isempty( cvx___.cones ),
            tt = true( 1, length( cvx___.cones ) );
            for k = 1 : length( cvx___.cones ),
                cvx___.cones( k ).indices( :, any( cvx___.cones( k ).indices, 1 ) ) = [];
                if isempty( cvx___.cones( k ).indices ), tt( k ) = false; end
            end
            cvx___.cones = cvx___.cones( 1, tt );
        end
    end
    if nf <= 2 | ne <= 1,
        cvx___.equalities = cvx( [ 0, 1 ], [] );
        cvx___.needslack = ( logical( zeros( 0, 1 ) ) );
    elseif size( cvx___.equalities, 2 ) >= ne,
        cvx___.equalities( ne : end ) = [];
        cvx___.needslack( ne : end ) = [];
    end
    if nf <= 2 | nl <= 1,
        cvx___.linforms = cvx( [ 0, 1 ], [] );
        cvx___.linrepls = cvx( [ 0, 1 ], [] );
    elseif size( cvx___.linforms, 2 ) >= nl,
        cvx___.linforms( nl : end ) = [];
        cvx___.linrepls( nl : end ) = [];
    end
    if nf <= 2 | nu <= 1,
        cvx___.uniforms = cvx( [ 0, 1 ], [] );
        cvx___.unirepls = cvx( [ 0, 1 ], [] );
    elseif size( cvx___.uniforms, 2 ) >= nu,
        cvx___.uniforms( nu : end ) = [];
        cvx___.unirepls( nu : end ) = [];
    end
end

%
% Clear the workspace
%

if ~isequal( clearmode, 'reset' ),
    evalin( 'caller', 'clear cvx___' );
    s1 = evalin( 'caller', 'who' );
    if cvx___.mversion < 7.1,
        nvars = prod( size( s1 ) );
        s2 = zeros( 1, nvars );
        for k = 1 : nvars,
            s2(k) = cvx_id( evalin( 'caller', s1{k} ) );
        end
    else
        s2 = sprintf( '%s, ', s1{:} );
        s2 = evalin( 'caller', sprintf( 'cellfun( @cvx_id, { %s } )', s2(1:end-2) ) );
    end
    tt = s2 >= pid;
    s1 = s1( tt );
    s2 = s2( tt );
    if ~isempty( s1 ),
        switch clearmode,
            case 'value',
                tt = s2 == pid;
                if any( tt ),
                    evalin( 'caller', sprintf( '%s ', 'clear ', s1{tt} ) );
                    s1(tt) = [];
                end
                if ~isempty( s1 ),
                    temp = sprintf( '%s, ', s1{:} );
                    temp(end-1:end) = [];
                    evalin( 'caller', sprintf( '[ %s ] = cvx_values( %s );', temp, temp ) );
                end
            case 'clear',
                evalin( 'caller', sprintf( '%s ', 'clear', s1{:} ) );
            case 'none',
                tt = find( s2 == pid );
                if any( tt ),
                    evalin( 'caller', sprintf( '%s ', 'clear', s1{tt} ) );
                end
        end
    end
end

%
% Clear the problem stack and value vectors
%

cvx___.problems( p : end ) = [];
cvx___.x = [];
cvx___.y = [];