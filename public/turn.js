$(function() {
    $('.moji').click(function() {
        $(this).fadeTo( "fast", 0.33 );
        if($(this).hasClass('guessed')) {
            return
        }
        $(this).addClass('guessed');
        const gameId = $("#game-id").val();
        const playerId = localStorage.getItem(gameId);
        const moji = $(this).text();
        $.post(`/game/${gameId}/turn/${playerId}/guess`, JSON.stringify({"emoji": moji}),function(data){
            $("#points").fadeOut(100);
            $("#points").text(data.player_points);
            $("#points").fadeIn(100);
        }).fail(function(e) {
            console.log(e.responseText);
            if(e.responseText === "game over"){
                console.log("byeeeee");
                window.location.href = `/game/${gameId}`;
                return;
            } else {
                alert("Oh no, we couldn't submit your guess.");
            }
        });
    }); 

    $('#next-turn-button').click(function(){
        const gameId = $("#game-id").val();
        const playerId = localStorage.getItem(gameId);
        $(this).addClass('is-loading');
        $(this).prop('disabled', true);
        $.post(`/game/${gameId}/turn/${playerId}`, function(joinData){
            window.location.href = `/game/${gameId}/turn/${playerId}`;
        }).fail(function(e){
            console.log(e.responseText);
            if(e.responseText === "game over"){
                console.log("byeeeee");
                window.location.href = `/game/${gameId}`;
                return;
            } else {
                alert("Oh no, we couldn't get a next image.");    
            }
        });
    });
});