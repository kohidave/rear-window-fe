$(function() {
    $('#start-game').submit(function(e) {
        e.preventDefault();
        $("#start-game-button").prop('disabled', true);
        $("#start-game-button").addClass('is-loading');
        const username = $("#start-game-name").val();
        console.log("doin it for " + username);
        $.post('/game', function(data){
            const gameId = data.game_id;
            $.post(`/game/${gameId}/member/${username}`, function(joinData){
                localStorage.setItem(gameId, joinData.user_id);
                window.location.href = `/game/${gameId}`;
            }).fail(function(e){
                console.log(e);
                alert("Oh no, we couldn't join your game.");    
            });
        }).fail(function(e) {
            console.log(e);
            alert("Oh no, we couldn't start your game.");
        });
    }); 
});