import React, { createContext, useContext, useState, useEffect } from 'react';

type Language = 'en' | 'fr' | 'ar';

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string) => string;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [language, setLanguageState] = useState<Language>(() => {
    const saved = localStorage.getItem('language');
    return (saved as Language) || 'en';
  });

  useEffect(() => {
    localStorage.setItem('language', language);
    
    // Set RTL for Arabic
    if (language === 'ar') {
      document.documentElement.dir = 'rtl';
      document.documentElement.lang = 'ar';
    } else {
      document.documentElement.dir = 'ltr';
      document.documentElement.lang = language;
    }
  }, [language]);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
  };

  const t = (key: string): string => {
    const keys = key.split('.');
    let value: any = translations[language];
    
    for (const k of keys) {
      value = value?.[k];
    }
    
    return value || key;
  };

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within LanguageProvider');
  }
  return context;
}

// Translation data
const translations = {
  en: {
    // Common
    common: {
      save: 'Save',
      cancel: 'Cancel',
      edit: 'Edit',
      delete: 'Delete',
      submit: 'Submit',
      viewAll: 'View All',
      back: 'Back',
      logout: 'Logout',
      loading: 'Loading...',
      search: 'Search',
      filter: 'Filter',
      download: 'Download',
      upload: 'Upload',
      close: 'Close',
      confirm: 'Confirm',
      view: 'View',
      add: 'Add',
      create: 'Create',
      update: 'Update',
    },
    
    // Auth
    auth: {
      login: 'Login',
      register: 'Register',
      phoneNumber: 'Phone Number',
      pin: 'PIN (4 digits)',
      pinLabel: 'PIN',
      rememberMe: 'Remember me',
      forgotPin: 'Forgot PIN?',
      loginButton: 'Sign In',
      registerButton: 'Create Account',
      fullName: 'Full Name',
      email: 'Email Address',
      selectRole: 'Select Role',
      selectLanguage: 'Select Your Language',
      student: 'Student',
      teacher: 'Teacher',
      haveAccount: 'Already have an account?',
      noAccount: "Don't have an account?",
      welcomeBack: 'Welcome Back',
      loginSubtitle: 'Sign in to continue to Nouadhibou High School',
      createAccount: 'Create Account',
      registerSubtitle: 'Join Nouadhibou High School Platform',
      createAccountTitle: 'Create your account to get started',
      iAmA: 'I am a:',
      enterFullName: 'Enter your full name',
      enterPhoneNumber: 'Enter your phone number',
      gradeExample: 'e.g., 10th Grade',
      subjectExample: 'e.g., Mathematics',
      enterPin: 'Enter your PIN',
      confirmPin: 'Confirm PIN',
      reenterPin: 'Re-enter your PIN',
      registrationSuccessful: 'Registration Successful!',
      teacherAccountPending: 'Your account is pending admin approval',
      canSignInNow: 'You can now sign in to your account',
      important: 'Important:',
      teacherApprovalMessage: 'Teacher accounts require administrator approval. You will receive an email notification once your account has been approved. Please check back later or contact the school administration.',
      studentAccountCreated: 'Your student account has been created successfully. You will be redirected to the login page shortly.',
      accountDetails: 'Account Details:',
      goToLogin: 'Go to Login',
    },
    
    // Navigation
    nav: {
      home: 'Home',
      classes: 'Classes',
      assignments: 'Assignments',
      timetable: 'Timetable',
      sessions: 'Live Sessions',
      profile: 'Profile',
      students: 'Students',
      analytics: 'Analytics',
      notifications: 'Notifications',
    },
    
    // Dashboard
    dashboard: {
      welcomeBack: 'Welcome back',
      overview: "Here's what's happening today",
      teachingOverview: "Here's your teaching overview",
    },
    
    // Profile
    profile: {
      myProfile: 'My Profile',
      editProfile: 'Edit Profile',
      languagePreference: 'Language Preference',
      chooseLanguage: 'Choose your preferred language',
      changesSaved: 'Changes saved successfully!',
      personalInfo: 'Personal Information',
      contactInfo: 'Contact Information',
      parentInfo: 'Parent Information',
      professionalInfo: 'Professional Information',
      name: 'Name',
      email: 'Email',
      phone: 'Phone',
      address: 'Address',
      parentName: 'Parent Name',
      parentPhone: 'Parent Phone',
      parentEmail: 'Parent Email',
      department: 'Department',
      officeHours: 'Office Hours',
      bio: 'Biography',
      qualifications: 'Qualifications',
      academicInfo: 'Academic Information',
      statistics: 'Statistics',
      averageGrade: 'Average Grade',
    },
    
    // Classes
    classes: {
      myClasses: 'My Classes',
      enrolledClasses: 'Enrolled Classes',
      students: 'Students',
      totalStudents: 'Total Students',
      viewClass: 'View Class',
      classDetails: 'Class Details',
      classSchedule: 'Class Schedule',
      classDescription: 'Class Description',
      instructor: 'Instructor',
      room: 'Room',
      schedule: 'Schedule',
      subject: 'Subject',
      grade: 'Grade',
      semester: 'Semester',
    },
    
    // Lessons
    lessons: {
      lessons: 'Lessons',
      completed: 'Completed',
      lessonDetails: 'Lesson Details',
      lessonContent: 'Lesson Content',
      materials: 'Materials',
      resources: 'Resources',
      duration: 'Duration',
      topic: 'Topic',
      description: 'Description',
      objectives: 'Objectives',
      videoLesson: 'Video Lesson',
      textContent: 'Text Content',
      pdfDocument: 'PDF Document',
      watchVideo: 'Watch Video',
      downloadPDF: 'Download PDF',
      markComplete: 'Mark as Complete',
    },
    
    // Assignments
    assignments: {
      assignments: 'Assignments',
      pending: 'Pending Assignments',
      graded: 'Graded',
      pendingGrading: 'Pending Grading',
      dueDate: 'Due Date',
      viewAll: 'View All Assignments',
      upcomingAssignments: 'Upcoming Assignments',
      assignmentDetails: 'Assignment Details',
      instructions: 'Instructions',
      attachments: 'Attachments',
      submission: 'Submission',
      submitAssignment: 'Submit Assignment',
      mySubmission: 'My Submission',
      submittedOn: 'Submitted On',
      score: 'Score',
      feedback: 'Feedback',
      resubmit: 'Resubmit',
      viewSubmission: 'View Submission',
      noSubmission: 'No submission yet',
      overdue: 'Overdue',
      submitted: 'Submitted',
      points: 'Points',
      totalPoints: 'Total Points',
      provideFeedback: 'Provide Feedback',
      enterGrade: 'Enter Grade',
      saveGrade: 'Save Grade',
    },
    
    // Live Sessions
    live: {
      liveSessions: 'Live Sessions',
      activeSessions: 'Active Live Sessions',
      joinSession: 'Join Session',
      upcomingSessions: 'Upcoming Live Sessions',
      startSession: 'Start Session',
      sessionDetails: 'Session Details',
      platform: 'Platform',
      meetingLink: 'Meeting Link',
      sessionDate: 'Session Date',
      sessionTime: 'Session Time',
      duration: 'Duration',
      host: 'Host',
      participants: 'Participants',
      agenda: 'Agenda',
      recording: 'Recording',
      noActiveSessions: 'No active sessions',
      noUpcomingSessions: 'No upcoming sessions',
      copyLink: 'Copy Link',
      linkCopied: 'Link copied!',
    },
    
    // Timetable
    timetable: {
      timetable: 'Timetable',
      weeklySchedule: 'Weekly Schedule',
      mySchedule: 'My Schedule',
      monday: 'Monday',
      tuesday: 'Tuesday',
      wednesday: 'Wednesday',
      thursday: 'Thursday',
      friday: 'Friday',
      saturday: 'Saturday',
      sunday: 'Sunday',
      morning: 'Morning',
      afternoon: 'Afternoon',
      noClassesToday: 'No classes today',
    },
    
    // Actions
    actions: {
      quickActions: 'Quick Actions',
      createAssignment: 'Create Assignment',
      scheduleSession: 'Schedule Session',
      viewSubmissions: 'View Submissions',
      createLesson: 'Create New Lesson',
      gradeSubmissions: 'Grade Submissions',
      manageStudents: 'Manage Students',
      viewAnalytics: 'View Analytics',
    },
    
    // Today
    today: {
      todayClasses: "Today's Classes",
      noClasses: 'No classes scheduled for today',
      todaySchedule: "Today's Schedule",
    },
    
    // Progress
    progress: {
      progressOverview: 'Progress Overview',
      overallProgress: 'Overall Progress',
      courseProgress: 'Course Progress',
      completionRate: 'Completion Rate',
      performance: 'Performance',
    },
    
    // Recent
    recent: {
      recentSubmissions: 'Recent Submissions',
      awaitingGrade: 'Awaiting Grade',
      recentActivity: 'Recent Activity',
    },
    
    // Students (Teacher view)
    students: {
      allStudents: 'All Students',
      studentList: 'Student List',
      studentDetails: 'Student Details',
      studentProgress: 'Student Progress',
      studentPerformance: 'Student Performance',
      enrolledIn: 'Enrolled In',
      viewProfile: 'View Profile',
      contactStudent: 'Contact Student',
      searchStudents: 'Search students...',
    },
    
    // Analytics
    analytics: {
      analytics: 'Analytics',
      overview: 'Overview',
      classPerformance: 'Class Performance',
      assignmentStats: 'Assignment Statistics',
      attendanceRate: 'Attendance Rate',
      averageScore: 'Average Score',
      submissionRate: 'Submission Rate',
      topPerformers: 'Top Performers',
      needsAttention: 'Needs Attention',
    },
    
    // Notifications
    notifications: {
      notifications: 'Notifications',
      markAsRead: 'Mark as Read',
      markAllRead: 'Mark All as Read',
      newAssignment: 'New Assignment',
      gradePosted: 'Grade Posted',
      upcomingClass: 'Upcoming Class',
      noNotifications: 'No notifications',
    },
  },
  
  fr: {
    // Common
    common: {
      save: 'Enregistrer',
      cancel: 'Annuler',
      edit: 'Modifier',
      delete: 'Supprimer',
      submit: 'Soumettre',
      viewAll: 'Voir tout',
      back: 'Retour',
      logout: 'Déconnexion',
      loading: 'Chargement...',
      search: 'Rechercher',
      filter: 'Filtrer',
      download: 'Télécharger',
      upload: 'Téléverser',
      close: 'Fermer',
      confirm: 'Confirmer',
      view: 'Voir',
      add: 'Ajouter',
      create: 'Créer',
      update: 'Mettre à jour',
    },
    
    // Auth
    auth: {
      login: 'Connexion',
      register: "S'inscrire",
      phoneNumber: 'Numéro de téléphone',
      pin: 'PIN (4 chiffres)',
      pinLabel: 'PIN',
      rememberMe: 'Se souvenir de moi',
      forgotPin: 'PIN oublié?',
      loginButton: 'Se connecter',
      registerButton: 'Créer un compte',
      fullName: 'Nom complet',
      email: 'Adresse e-mail',
      selectRole: 'Sélectionner le rôle',
      selectLanguage: 'Sélectionner votre langue',
      student: 'Étudiant',
      teacher: 'Enseignant',
      haveAccount: 'Vous avez déjà un compte?',
      noAccount: "Vous n'avez pas de compte?",
      welcomeBack: 'Bon retour',
      loginSubtitle: 'Connectez-vous pour continuer à Nouadhibou High School',
      createAccount: 'Créer un compte',
      registerSubtitle: 'Rejoignez la plateforme Nouadhibou High School',
      createAccountTitle: 'Créez votre compte pour commencer',
      iAmA: 'Je suis un(e) :',
      enterFullName: 'Entrez votre nom complet',
      enterPhoneNumber: 'Entrez votre numéro de téléphone',
      gradeExample: 'ex. 10ème année',
      subjectExample: 'ex. Mathématiques',
      enterPin: 'Entrez votre PIN',
      confirmPin: 'Confirmez le PIN',
      reenterPin: 'Retapez votre PIN',
      registrationSuccessful: 'Inscription réussie !',
      teacherAccountPending: 'Votre compte est en attente d\'approbation de l\'administrateur',
      canSignInNow: 'Vous pouvez maintenant vous connecter à votre compte',
      important: 'Important :',
      teacherApprovalMessage: 'Les comptes enseignant nécessitent l\'approbation de l\'administrateur. Vous recevrez une notification par e-mail une fois que votre compte aura été approuvé. Veuillez vérifier plus tard ou contacter l\'administration de l\'école.',
      studentAccountCreated: 'Votre compte étudiant a été créé avec succès. Vous serez redirigé vers la page de connexion bientôt.',
      accountDetails: 'Détails du compte :',
      goToLogin: 'Aller à la connexion',
    },
    
    // Navigation
    nav: {
      home: 'Accueil',
      classes: 'Cours',
      assignments: 'Devoirs',
      timetable: 'Emploi du temps',
      sessions: 'Sessions en direct',
      profile: 'Profil',
      students: 'Étudiants',
      analytics: 'Analytique',
      notifications: 'Notifications',
    },
    
    // Dashboard
    dashboard: {
      welcomeBack: 'Bon retour',
      overview: "Voici ce qui se passe aujourd'hui",
      teachingOverview: "Voici votre aperçu de l'enseignement",
    },
    
    // Profile
    profile: {
      myProfile: 'Mon profil',
      editProfile: 'Modifier le profil',
      languagePreference: 'Préférence de langue',
      chooseLanguage: 'Choisissez votre langue préférée',
      changesSaved: 'Modifications enregistrées avec succès!',
      personalInfo: 'Informations personnelles',
      contactInfo: 'Informations de contact',
      parentInfo: 'Informations parentales',
      professionalInfo: 'Informations professionnelles',
      name: 'Nom',
      email: 'E-mail',
      phone: 'Téléphone',
      address: 'Adresse',
      parentName: 'Nom du parent',
      parentPhone: 'Téléphone du parent',
      parentEmail: 'E-mail du parent',
      department: 'Département',
      officeHours: 'Heures de bureau',
      bio: 'Biographie',
      qualifications: 'Qualifications',
      academicInfo: 'Informations académiques',
      statistics: 'Statistiques',
      averageGrade: 'Note moyenne',
    },
    
    // Classes
    classes: {
      myClasses: 'Mes cours',
      enrolledClasses: 'Cours inscrits',
      students: 'Étudiants',
      totalStudents: 'Total étudiants',
      viewClass: 'Voir le cours',
      classDetails: 'Détails du cours',
      classSchedule: 'Horaire du cours',
      classDescription: 'Description du cours',
      instructor: 'Instructeur',
      room: 'Salle',
      schedule: 'Horaire',
      subject: 'Matière',
      grade: 'Niveau',
      semester: 'Semestre',
    },
    
    // Lessons
    lessons: {
      lessons: 'Leçons',
      completed: 'Terminé',
      lessonDetails: 'Détails de la leçon',
      lessonContent: 'Contenu de la leçon',
      materials: 'Matériaux',
      resources: 'Ressources',
      duration: 'Durée',
      topic: 'Sujet',
      description: 'Description',
      objectives: 'Objectifs',
      videoLesson: 'Leçon vidéo',
      textContent: 'Contenu textuel',
      pdfDocument: 'Document PDF',
      watchVideo: 'Regarder la vidéo',
      downloadPDF: 'Télécharger le PDF',
      markComplete: 'Marquer comme terminé',
    },
    
    // Assignments
    assignments: {
      assignments: 'Devoirs',
      pending: 'Devoirs en attente',
      graded: 'Noté',
      pendingGrading: 'Notation en attente',
      dueDate: "Date d'échéance",
      viewAll: 'Voir tous les devoirs',
      upcomingAssignments: 'Devoirs à venir',
      assignmentDetails: 'Détails du devoir',
      instructions: 'Instructions',
      attachments: 'Pièces jointes',
      submission: 'Soumission',
      submitAssignment: 'Soumettre le devoir',
      mySubmission: 'Ma soumission',
      submittedOn: 'Soumis le',
      score: 'Score',
      feedback: 'Commentaires',
      resubmit: 'Resoumettre',
      viewSubmission: 'Voir la soumission',
      noSubmission: 'Aucune soumission encore',
      overdue: 'En retard',
      submitted: 'Soumis',
      points: 'Points',
      totalPoints: 'Points totaux',
      provideFeedback: 'Fournir des commentaires',
      enterGrade: 'Entrer la note',
      saveGrade: 'Enregistrer la note',
    },
    
    // Live Sessions
    live: {
      liveSessions: 'Sessions en direct',
      activeSessions: 'Sessions en direct actives',
      joinSession: 'Rejoindre la session',
      upcomingSessions: 'Sessions en direct à venir',
      startSession: 'Démarrer la session',
      sessionDetails: 'Détails de la session',
      platform: 'Plateforme',
      meetingLink: 'Lien de réunion',
      sessionDate: 'Date de la session',
      sessionTime: 'Heure de la session',
      duration: 'Durée',
      host: 'Hôte',
      participants: 'Participants',
      agenda: 'Ordre du jour',
      recording: 'Enregistrement',
      noActiveSessions: 'Aucune session active',
      noUpcomingSessions: 'Aucune session à venir',
      copyLink: 'Copier le lien',
      linkCopied: 'Lien copié!',
    },
    
    // Timetable
    timetable: {
      timetable: 'Emploi du temps',
      weeklySchedule: 'Horaire hebdomadaire',
      mySchedule: 'Mon horaire',
      monday: 'Lundi',
      tuesday: 'Mardi',
      wednesday: 'Mercredi',
      thursday: 'Jeudi',
      friday: 'Vendredi',
      saturday: 'Samedi',
      sunday: 'Dimanche',
      morning: 'Matin',
      afternoon: 'Après-midi',
      noClassesToday: "Pas de cours aujourd'hui",
    },
    
    // Actions
    actions: {
      quickActions: 'Actions rapides',
      createAssignment: 'Créer un devoir',
      scheduleSession: 'Planifier une session',
      viewSubmissions: 'Voir les soumissions',
      createLesson: 'Créer une nouvelle leçon',
      gradeSubmissions: 'Noter les soumissions',
      manageStudents: 'Gérer les étudiants',
      viewAnalytics: "Voir l'analytique",
    },
    
    // Today
    today: {
      todayClasses: "Cours d'aujourd'hui",
      noClasses: "Aucun cours prévu aujourd'hui",
      todaySchedule: "Horaire d'aujourd'hui",
    },
    
    // Progress
    progress: {
      progressOverview: 'Aperçu des progrès',
      overallProgress: 'Progrès global',
      courseProgress: 'Progrès du cours',
      completionRate: "Taux d'achèvement",
      performance: 'Performance',
    },
    
    // Recent
    recent: {
      recentSubmissions: 'Soumissions récentes',
      awaitingGrade: 'En attente de note',
      recentActivity: 'Activité récente',
    },
    
    // Students (Teacher view)
    students: {
      allStudents: 'Tous les étudiants',
      studentList: 'Liste des étudiants',
      studentDetails: "Détails de l'étudiant",
      studentProgress: "Progrès de l'étudiant",
      studentPerformance: "Performance de l'étudiant",
      enrolledIn: 'Inscrit dans',
      viewProfile: 'Voir le profil',
      contactStudent: "Contacter l'étudiant",
      searchStudents: 'Rechercher des étudiants...',
    },
    
    // Analytics
    analytics: {
      analytics: 'Analytique',
      overview: 'Aperçu',
      classPerformance: 'Performance de la classe',
      assignmentStats: 'Statistiques des devoirs',
      attendanceRate: 'Taux de présence',
      averageScore: 'Score moyen',
      submissionRate: 'Taux de soumission',
      topPerformers: 'Meilleurs performeurs',
      needsAttention: "Nécessite de l'attention",
    },
    
    // Notifications
    notifications: {
      notifications: 'Notifications',
      markAsRead: 'Marquer comme lu',
      markAllRead: 'Marquer tout comme lu',
      newAssignment: 'Nouveau devoir',
      gradePosted: 'Note publiée',
      upcomingClass: 'Cours à venir',
      noNotifications: 'Aucune notification',
    },
  },
  
  ar: {
    // Common
    common: {
      save: 'حفظ',
      cancel: 'إلغاء',
      edit: 'تعديل',
      delete: 'حذف',
      submit: 'إرسال',
      viewAll: 'عرض الكل',
      back: 'رجوع',
      logout: 'تسجيل الخروج',
      loading: 'جاري التحميل...',
      search: 'بحث',
      filter: 'تصفية',
      download: 'تحميل',
      upload: 'رفع',
      close: 'إغلاق',
      confirm: 'تأكيد',
      view: 'عرض',
      add: 'إضافة',
      create: 'إنشاء',
      update: 'تحديث',
    },
    
    // Auth
    auth: {
      login: 'تسجيل الدخول',
      register: 'التسجيل',
      phoneNumber: 'رقم الهاتف',
      pin: 'رمز PIN (4 أرقام)',
      pinLabel: 'PIN',
      rememberMe: 'تذكرني',
      forgotPin: 'نسيت رمز PIN؟',
      loginButton: 'تسجيل الدخول',
      registerButton: 'إنشاء حساب',
      fullName: 'الاسم الكامل',
      email: 'البريد الإلكتروني',
      selectRole: 'اختر الدور',
      selectLanguage: 'اختر لغتك',
      student: 'طالب',
      teacher: 'معلم',
      haveAccount: 'هل لديك حساب بالفعل؟',
      noAccount: 'ليس لديك حساب؟',
      welcomeBack: 'مرحباً بعودتك',
      loginSubtitle: 'سجل الدخول للمتابعة إلى مدرسة نواذيبو الثانوية',
      createAccount: 'إنشاء حساب',
      registerSubtitle: 'انضم إلى منصة مدرسة نواذيبو الثانوية',
      createAccountTitle: 'إنشاء حسابك للبدء',
      iAmA: 'أنا :',
      enterFullName: 'أدخل اسمك الكامل',
      enterPhoneNumber: 'أدخل رقم هاتفك',
      gradeExample: 'مثال: الصف العاشر',
      subjectExample: 'مثال: الرياضيات',
      enterPin: 'أدخل رمز PINك',
      confirmPin: 'تأكيد رمز PINك',
      reenterPin: 'أعد إدخال رمز PINك',
      registrationSuccessful: 'تم التسجيل بنجاح!',
      teacherAccountPending: 'حسابك معلق بانتظار موافقة المسؤول',
      canSignInNow: 'يمكنك الآن تسجيل الدخول إلى حسابك',
      important: 'مهم:',
      teacherApprovalMessage: 'يحتاج حسابات المعلمين إلى موافقة المسؤول. سترسل إليك إشعارًا عبر البريد الإلكتروني بمجرد الموافقة على حسابك. يرجى التحقق لاحقًا أو الاتصال بمكتب إدارة المدرسة.',
      studentAccountCreated: 'تم إنشاء حسابك كطالب بنجاح. سيتم توجيهك إلى صفحة تسجيل الدخول قريباً.',
      accountDetails: 'تفاصيل الحساب:',
      goToLogin: 'الانتقال إلى تسجيل الدخول',
    },
    
    // Navigation
    nav: {
      home: 'الرئيسية',
      classes: 'الصفوف',
      assignments: 'الواجبات',
      timetable: 'الجدول الزمني',
      sessions: 'الجلسات المباشرة',
      profile: 'الملف الشخصي',
      students: 'الطلاب',
      analytics: 'التحليلات',
      notifications: 'الإشعارات',
    },
    
    // Dashboard
    dashboard: {
      welcomeBack: 'مرحباً بعودتك',
      overview: 'إلك ما يحدث اليوم',
      teachingOverview: 'إليك نظرة عامة على التدريس',
    },
    
    // Profile
    profile: {
      myProfile: 'ملفي الشخصي',
      editProfile: 'تعديل الملف الشخصي',
      languagePreference: 'تفضيل اللغة',
      chooseLanguage: 'اختر لغتك المفضلة',
      changesSaved: 'تم حفظ التغييرات بنجاح!',
      personalInfo: 'المعلومات الشخصية',
      contactInfo: 'معلومات الاتصال',
      parentInfo: 'معلومات ولي الأمر',
      professionalInfo: 'المعلومات المهنية',
      name: 'الاسم',
      email: 'البريد الإلكتروني',
      phone: 'الهاتف',
      address: 'العنوان',
      parentName: 'اسم ولي الأمر',
      parentPhone: 'هاتف ولي الأمر',
      parentEmail: 'بريد ولي الأمر الإلكتروني',
      department: 'القسم',
      officeHours: 'ساعات العمل',
      bio: 'السيرة الذاتية',
      qualifications: 'المؤهلات',
      academicInfo: 'المعلومات الأكاديمية',
      statistics: 'الإحصائيات',
      averageGrade: 'المعدل',
    },
    
    // Classes
    classes: {
      myClasses: 'صفوفي',
      enrolledClasses: 'الصفوف المسجلة',
      students: 'الطلاب',
      totalStudents: 'إجمالي الطلاب',
      viewClass: 'عرض الصف',
      classDetails: 'تفاصيل الصف',
      classSchedule: 'جدول الصف',
      classDescription: 'وصف الصف',
      instructor: 'المدرس',
      room: 'الغرفة',
      schedule: 'الجدول',
      subject: 'المادة',
      grade: 'الدرجة',
      semester: 'الفصل الدراسي',
    },
    
    // Lessons
    lessons: {
      lessons: 'الدروس',
      completed: 'مكتمل',
      lessonDetails: 'تفاصيل الدرس',
      lessonContent: 'محتوى الدرس',
      materials: 'المواد',
      resources: 'الموارد',
      duration: 'المدة',
      topic: 'الموضوع',
      description: 'الوصف',
      objectives: 'الأهداف',
      videoLesson: 'درس فيديو',
      textContent: 'محتوى نصي',
      pdfDocument: 'مستند PDF',
      watchVideo: 'مشاهدة الفيديو',
      downloadPDF: 'تحميل PDF',
      markComplete: 'وضع علامة مكتمل',
    },
    
    // Assignments
    assignments: {
      assignments: 'الواجبات',
      pending: 'الواجبات المعلقة',
      graded: 'تم التقييم',
      pendingGrading: 'في انتظار التقييم',
      dueDate: 'تاريخ الاستحقاق',
      viewAll: 'عرض جميع الواجبات',
      upcomingAssignments: 'الواجبات القادمة',
      assignmentDetails: 'تفاصيل الواجب',
      instructions: 'التعليمات',
      attachments: 'المرفقات',
      submission: 'التسليم',
      submitAssignment: 'تسليم الواجب',
      mySubmission: 'تسليمي',
      submittedOn: 'تم التسليم في',
      score: 'الدرجة',
      feedback: 'التعليقات',
      resubmit: 'إعادة التسليم',
      viewSubmission: 'عرض التسليم',
      noSubmission: 'لا يوجد تسليم بعد',
      overdue: 'متأخر',
      submitted: 'تم التسليم',
      points: 'نقاط',
      totalPoints: 'النقاط الإجمالية',
      provideFeedback: 'تقديم التعليقات',
      enterGrade: 'إدخال الدرجة',
      saveGrade: 'حفظ الدرجة',
    },
    
    // Live Sessions
    live: {
      liveSessions: 'الجلسات المباشرة',
      activeSessions: 'الجلسات المباشرة النشطة',
      joinSession: 'الانضمام للجلسة',
      upcomingSessions: 'الجلسات المباشرة القادمة',
      startSession: 'بدء الجلسة',
      sessionDetails: 'تفاصيل الجلسة',
      platform: 'المنصة',
      meetingLink: 'رابط الاجتماع',
      sessionDate: 'تاريخ الجلسة',
      sessionTime: 'وقت الجلسة',
      duration: 'المدة',
      host: 'المضيف',
      participants: 'المشاركون',
      agenda: 'جدول الأعمال',
      recording: 'التسجيل',
      noActiveSessions: 'لا توجد جلسات نشطة',
      noUpcomingSessions: 'لا توجد جلسات قادمة',
      copyLink: 'نسخ الرابط',
      linkCopied: 'تم نسخ الرابط!',
    },
    
    // Timetable
    timetable: {
      timetable: 'الجدول الزمني',
      weeklySchedule: 'الجدول الأسبوعي',
      mySchedule: 'جدولي',
      monday: 'الاثنين',
      tuesday: 'الثلاثاء',
      wednesday: 'الأربعاء',
      thursday: 'الخميس',
      friday: 'الجمعة',
      saturday: 'السبت',
      sunday: 'الأحد',
      morning: 'صباحاً',
      afternoon: 'مساءً',
      noClassesToday: 'لا توجد صفوف اليوم',
    },
    
    // Actions
    actions: {
      quickActions: 'إجراءات سريعة',
      createAssignment: 'إنشاء واجب',
      scheduleSession: 'جدولة جلسة',
      viewSubmissions: 'عرض التسليمات',
      createLesson: 'إنشاء درس جديد',
      gradeSubmissions: 'تقييم التسليمات',
      manageStudents: 'إدارة الطلاب',
      viewAnalytics: 'عرض التحليلات',
    },
    
    // Today
    today: {
      todayClasses: 'صفوف اليوم',
      noClasses: 'لا توجد صفوف مجدولة لليوم',
      todaySchedule: 'جدول اليوم',
    },
    
    // Progress
    progress: {
      progressOverview: 'نظرة عامة على التقدم',
      overallProgress: 'التقدم الإجمالي',
      courseProgress: 'تقدم الدورة',
      completionRate: 'معدل الإنجاز',
      performance: 'الأداء',
    },
    
    // Recent
    recent: {
      recentSubmissions: 'التسليمات الأخيرة',
      awaitingGrade: 'في انتظار الدرجة',
      recentActivity: 'النشاط الأخير',
    },
    
    // Students (Teacher view)
    students: {
      allStudents: 'جميع الطلاب',
      studentList: 'قائمة الطلاب',
      studentDetails: 'تفاصيل الطالب',
      studentProgress: 'تقدم الطالب',
      studentPerformance: 'أداء الطالب',
      enrolledIn: 'مسجل في',
      viewProfile: 'عرض الملف الشخصي',
      contactStudent: 'الاتصال بالطالب',
      searchStudents: 'البحث عن الطلاب...',
    },
    
    // Analytics
    analytics: {
      analytics: 'التحليلات',
      overview: 'نظرة عامة',
      classPerformance: 'أداء الصف',
      assignmentStats: 'إحصائيات الواجبات',
      attendanceRate: 'معدل الحضور',
      averageScore: 'الدرجة المتوسطة',
      submissionRate: 'معدل التسليم',
      topPerformers: 'أفضل الأداء',
      needsAttention: 'يحتاج إلى اهتمام',
    },
    
    // Notifications
    notifications: {
      notifications: 'الإشعارات',
      markAsRead: 'وضع علامة كمقروء',
      markAllRead: 'وضع علامة على الكل كمقروء',
      newAssignment: 'واجب جديد',
      gradePosted: 'تم نشر الدرجة',
      upcomingClass: 'صف قادم',
      noNotifications: 'لا توجد إشعارات',
    },
  },
};