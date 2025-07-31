<?php
session_start();
require_once 'db.php';

// Vérifier que l'utilisateur est connecté et autorisé (admin, médecin principal ou intérimaire)
if (!isset($_SESSION['user']) || !in_array($_SESSION['user']['role'], ['admin', 'medecin'])) {
    header("Location: login.php");
    exit();
}


$user_id = $_SESSION['user']['id_utilisateur'];
$user_role = $_SESSION['user']['role'];
$username = $_SESSION['user']['username'];

include 'includes/header.php';
// Inclure le bon sidebar selon le rôle
if ($user_role === 'admin') {
    include 'includes/sidebar-admin.php';
} else {
    include 'includes/sidebar-medecin.php';
}
?>

<style>
.chat-container {
    height: 600px;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    background: white;
}

.chat-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1rem;
    border-radius: 8px 8px 0 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 1rem;
    background-color: #f9fafb;
}

.message {
    margin-bottom: 1rem;
    display: flex;
    align-items: flex-start;
}

.message.own {
    flex-direction: row-reverse;
}

.message-content {
    max-width: 70%;
    padding: 0.75rem 1rem;
    border-radius: 1rem;
    position: relative;
}

.message.own .message-content {
    background-color: #3b82f6;
    color: white;
    border-bottom-right-radius: 0.25rem;
}

.message:not(.own) .message-content {
    background-color: white;
    border: 1px solid #e5e7eb;
    border-bottom-left-radius: 0.25rem;
}

.message-info {
    font-size: 0.75rem;
    opacity: 0.7;
    margin-top: 0.25rem;
}

.message.own .message-info {
    text-align: right;
}

.user-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    color: white;
    margin: 0 0.5rem;
    flex-shrink: 0;
}

.admin-avatar {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.medecin-avatar {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.chat-input-area {
    padding: 1rem;
    border-top: 1px solid #e5e7eb;
    background: white;
    border-radius: 0 0 8px 8px;
}

.chat-input {
    display: flex;
    gap: 0.5rem;
    align-items: center;
}

.chat-input input {
    flex: 1;
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 25px;
    outline: none;
    font-size: 0.9rem;
}

.chat-input input:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.send-btn {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 50%;
    width: 45px;
    height: 45px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: transform 0.2s;
}

.send-btn:hover {
    transform: scale(1.05);
}

.send-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none;
}

.online-indicator {
    width: 8px;
    height: 8px;
    background: #10b981;
    border-radius: 50%;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}

.typing-indicator {
    padding: 0.5rem 1rem;
    font-style: italic;
    color: #6b7280;
    font-size: 0.875rem;
}

.system-message {
    text-align: center;
    color: #6b7280;
    font-size: 0.875rem;
    margin: 1rem 0;
    font-style: italic;
}

/* Animations */
.message {
    animation: fadeInUp 0.3s ease;
}

@keyframes fadeInUp {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.stat-card {
    transition: all 0.3s ease;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
</style>

<div class="pc-container">
    <div class="pc-content">
        <div class="page-header">
            <div class="page-block">
                <div class="page-header-title">
                    <h5 class="mb-0 font-medium">
                        <i class="fas fa-comments me-2"></i>Discussion médicale
                    </h5>
                </div>
                <ul class="breadcrumb">
                    <li class="breadcrumb-item">
                        <a href="<?= $user_role === 'admin' ? 'dashboard-admin.php' : 'dashboard-medecin.php' ?>">
                            Tableau de bord
                        </a>
                    </li>
                    <li class="breadcrumb-item active">Chat</li>
                </ul>
            </div>
        </div>

        <!-- Statistiques rapides du chat -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stat-card bg-white p-3 border-l-4 border-blue-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-blue-100 rounded-lg mr-3">
                            <i class="fas fa-users text-blue-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="text-sm font-medium text-gray-600">Utilisateurs actifs</p>
                            <p class="text-lg font-bold text-blue-600" id="activeUsers">-</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card bg-white p-3 border-l-4 border-green-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-green-100 rounded-lg mr-3">
                            <i class="fas fa-comment text-green-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="text-sm font-medium text-gray-600">Messages aujourd'hui</p>
                            <p class="text-lg font-bold text-green-600" id="todayMessages">-</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card bg-white p-3 border-l-4 border-yellow-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-yellow-100 rounded-lg mr-3">
                            <i class="fas fa-clock text-yellow-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="text-sm font-medium text-gray-600">Dernière activité</p>
                            <p class="text-sm font-bold text-yellow-600" id="lastActivity">-</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card bg-white p-3 border-l-4 border-indigo-500">
                    <div class="flex items-center">
                        <div class="p-2 bg-indigo-100 rounded-lg mr-3">
                            <i class="fas fa-bell text-indigo-600"></i>
                        </div>
                        <div class="flex-1">
                            <p class="text-sm font-medium text-gray-600">Messages non lus</p>
                            <p class="text-lg font-bold text-indigo-600" id="unreadMessages">-</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Zone de chat principale -->
        <div class="row">
            <div class="col-12">
                <div class="chat-container">
                    <div class="chat-header">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-comments me-2"></i>
                            <h6 class="mb-0">Discussion Médicale Générale</h6>
                            <div class="online-indicator ms-2"></div>
                        </div>
                        <div class="d-flex align-items-center">
                            <span class="badge bg-light text-dark me-2">
                                <i class="fas fa-user me-1"></i>
                                <?= htmlspecialchars($username) ?>
                            </span>
                            <small class="opacity-75">
                                <?= $user_role === 'admin' ? 'Administrateur' : 'Médecin' ?>
                            </small>
                        </div>
                    </div>
                    
                    <div class="chat-messages" id="chatMessages">
                        <div class="system-message">
                            <i class="fas fa-info-circle me-1"></i>
                            Bienvenue dans l'espace de discussion médicale
                        </div>
                    </div>
                    
                    <div class="typing-indicator" id="typingIndicator" style="display: none;">
                        <i class="fas fa-ellipsis-h"></i> Quelqu'un est en train d'écrire...
                    </div>
                    
                    <div class="chat-input-area">
                        <div class="chat-input">
                            <input type="text" 
                                   id="messageInput" 
                                   placeholder="Tapez votre message ici..." 
                                   maxlength="1000"
                                   autocomplete="off">
                            <button type="button" class="send-btn" id="sendBtn">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </div>
                        <small class="text-muted mt-1">
                            <i class="fas fa-shield-alt me-1"></i>
                            Discussion sécurisée entre professionnels de santé
                        </small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js"></script>
<script>
class MedicalChat {
    constructor() {
        this.userId = <?= $user_id ?>;
        this.username = '<?= htmlspecialchars($username) ?>';
        this.userRole = '<?= $user_role ?>';
        this.lastMessageId = 0;
        this.isTyping = false;
        this.typingTimeout = null;
        
        this.initializeElements();
        this.bindEvents();
        this.loadMessages();
        this.startPolling();
        this.loadStats();
    }
    
    initializeElements() {
        this.chatMessages = document.getElementById('chatMessages');
        this.messageInput = document.getElementById('messageInput');
        this.sendBtn = document.getElementById('sendBtn');
        this.typingIndicator = document.getElementById('typingIndicator');
    }
    
    bindEvents() {
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.sendMessage();
            } else {
                this.handleTyping();
            }
        });
        
        this.messageInput.addEventListener('input', () => {
            this.handleTyping();
        });
    }
    
    handleTyping() {
        if (!this.isTyping) {
            this.isTyping = true;
            // Ici on peut ajouter une notification de frappe si nécessaire
        }
        
        clearTimeout(this.typingTimeout);
        this.typingTimeout = setTimeout(() => {
            this.isTyping = false;
        }, 2000);
    }
    
    async sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message) return;
        
        this.sendBtn.disabled = true;
        this.messageInput.disabled = true;
        
        try {
            const response = await fetch('chat_api.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    action: 'send_message',
                    message: message
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.messageInput.value = '';
                this.loadMessages();
            } else {
                alert('Erreur lors de l\'envoi du message: ' + result.message);
            }
        } catch (error) {
            console.error('Erreur:', error);
            alert('Erreur de connexion');
        } finally {
            this.sendBtn.disabled = false;
            this.messageInput.disabled = false;
            this.messageInput.focus();
        }
    }
    
    async loadMessages() {
        try {
            const response = await fetch(`chat_api.php?action=get_messages&last_id=${this.lastMessageId}`);
            const result = await response.json();
            
            if (result.success && result.messages.length > 0) {
                result.messages.forEach(message => {
                    this.addMessageToChat(message);
                    this.lastMessageId = Math.max(this.lastMessageId, message.id_message);
                });
                
                this.scrollToBottom();
            }
        } catch (error) {
            console.error('Erreur lors du chargement des messages:', error);
        }
    }
    
    addMessageToChat(message) {
        const isOwn = message.id_utilisateur == this.userId;
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${isOwn ? 'own' : ''}`;
        
        const avatarClass = message.role === 'admin' ? 'admin-avatar' : 'medecin-avatar';
        const roleText = message.role === 'admin' ? 'Admin' : 'Médecin';
        
        messageDiv.innerHTML = `
            ${!isOwn ? `<div class="user-avatar ${avatarClass}">
                ${message.username.charAt(0).toUpperCase()}
            </div>` : ''}
            <div class="message-content">
                <div class="message-text">${this.escapeHtml(message.message)}</div>
                <div class="message-info">
                    ${!isOwn ? `${message.username} (${roleText}) • ` : ''}
                    ${moment(message.date_message).format('HH:mm')}
                </div>
            </div>
            ${isOwn ? `<div class="user-avatar ${avatarClass}">
                ${this.username.charAt(0).toUpperCase()}
            </div>` : ''}
        `;
        
        this.chatMessages.appendChild(messageDiv);
    }
    
    scrollToBottom() {
        this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
    }
    
    startPolling() {
        setInterval(() => {
            this.loadMessages();
            this.loadStats();
        }, 3000); // Vérifier les nouveaux messages toutes les 3 secondes
    }
    
    async loadStats() {
        try {
            const response = await fetch('chat_api.php?action=get_stats');
            const result = await response.json();
            
            if (result.success) {
                document.getElementById('activeUsers').textContent = result.stats.activeUsers;
                document.getElementById('todayMessages').textContent = result.stats.todayMessages;
                document.getElementById('unreadMessages').textContent = result.stats.unreadMessages;
                document.getElementById('lastActivity').textContent = result.stats.lastActivity;
            }
        } catch (error) {
            console.error('Erreur lors du chargement des statistiques:', error);
        }
    }
    
    escapeHtml(text) {
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text.replace(/[&<>"']/g, m => map[m]);
    }
}

// Initialiser le chat quand la page est chargée
document.addEventListener('DOMContentLoaded', () => {
    new MedicalChat();
});
</script>

<?php include 'includes/footer.php'; ?>